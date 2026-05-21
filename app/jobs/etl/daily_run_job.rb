module Etl
  class DailyRunJob < ApplicationJob
    queue_as :etl
    sidekiq_options retry: 0

    STEPS = %w[download_studies].freeze

    # Maps step name → core's full class name in support.etl_jobs.type.
    # Cross-app contract: if core renames a class, update both sides + migrate existing rows.
    STI_CLASS = {
      "download_studies" => "Support::EtlJob::DownloadStudies"
    }.freeze

    # start_date: callers should always pass an explicit "yyyy-mm-dd" string.
    # The nil default exists to fall through to core's `get_sync_start_date`
    # (last incremental LoadEvent → Date.today - 5), which supports the legacy
    # `Util::UpdaterV2#execute` flow. v2-driven runs don't create LoadEvent
    # rows, so on the nil path core falls all the way to its 5-day default —
    # or worse, picks up a very old LoadEvent and backfills the full corpus.
    # Treat nil as transitional; compute the date on v2's side once ready.
    def perform(start_date: nil)
      guard_no_concurrent_run!
      run = EtlRun.create!(status: "running", started_at: Time.now)
      steps = create_step_rows(run)

      steps.each do |step|
        data = step.name == "download_studies" ? { start_date: start_date } : {}
        run_core_step(step, data: data)
      end

      run.update!(status: "complete", finished_at: Time.now)
    rescue StandardError
      run&.update!(status: "error", finished_at: Time.now)
      raise
    end

    private

    def guard_no_concurrent_run!
      return unless EtlRun.where(status: %w[pending running]).exists?
      raise "another etl run is in progress — aborting"
    end

    def create_step_rows(run)
      STEPS.each_with_index.map do |name, idx|
        run.steps.create!(name: name, position: idx + 1, status: "pending")
      end
    end

    def run_core_step(step, data:)
      job = Aact::EtlJob.create!(type: STI_CLASS.fetch(step.name), status: "pending", data: data)
      step.update!(core_job_id: job.id, status: "running", started_at: Time.now)

      loop do
        job.reload
        break if %w[complete error].include?(job.status)
        sleep 5
      end

      step.update!(status: job.status, finished_at: Time.now)
      raise "step #{step.name} failed (etl_jobs##{job.id}): #{job.logs&.lines&.first}" if job.status == "error"
    end
  end
end
