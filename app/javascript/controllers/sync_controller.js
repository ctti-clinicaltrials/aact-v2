import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "spinner", "text"]

  sync(event) {
    // Don't prevent default - let the form submit
    this.setLoading(true)
  }

  setLoading(loading) {
    if (loading) {
      this.buttonTarget.disabled = true
      this.textTarget.textContent = "Syncing..."
      this.spinnerTarget.classList.remove("hidden")
    } else {
      this.buttonTarget.disabled = false
      this.textTarget.textContent = "Sync Now"
      this.spinnerTarget.classList.add("hidden")
    }
  }

  // Called when Turbo Stream response is received
  complete() {
    this.setLoading(false)
  }
}
