module ApplicationHelper
  def flash_class(type)
    case type.to_sym
    when :notice, :success
      "bg-green-50 border border-green-200"
    when :alert, :error
      "bg-red-50 border border-red-200"
    when :info
      "bg-blue-50 border border-blue-200"
    else
      "bg-gray-50 border border-gray-200"
    end
  end

  def flash_text_class(type)
    case type.to_sym
    when :notice, :success
      "text-green-800"
    when :alert, :error
      "text-red-800"
    when :info
      "text-blue-800"
    else
      "text-gray-800"
    end
  end

  def flash_icon(type)
    case type.to_sym
    when :notice, :success
      <<~HTML.html_safe
        <svg class="h-5 w-5 text-green-400" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
        </svg>
      HTML
    when :alert, :error
      <<~HTML.html_safe
        <svg class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
        </svg>
      HTML
    when :info
      <<~HTML.html_safe
        <svg class="h-5 w-5 text-blue-400" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
        </svg>
      HTML
    else
      ""
    end
  end
end
