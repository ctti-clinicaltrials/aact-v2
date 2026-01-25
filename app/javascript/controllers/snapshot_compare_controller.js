import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "compareButton", "buttonText"]

  checkboxChanged() {
    const checkedBoxes = this.checkboxTargets.filter(cb => cb.checked)
    const count = checkedBoxes.length

    // Limit to 2 selections
    if (count > 2) {
      // Find the checkbox that was just checked (it's the one that pushed us over 2)
      const lastChecked = this.checkboxTargets.find(cb =>
        cb.checked && !checkedBoxes.slice(0, 2).includes(cb)
      )
      if (lastChecked) {
        lastChecked.checked = false
        return // Don't update button state since we prevented the check
      }
    }

    // Update button state
    this.updateButtonState(count)

    // Disable unchecked checkboxes if we have 2 selected
    this.checkboxTargets.forEach(cb => {
      if (!cb.checked && count === 2) {
        cb.disabled = true
      } else {
        cb.disabled = false
      }
    })
  }

  updateButtonState(count) {
    if (count === 2) {
      this.compareButtonTarget.disabled = false
      this.buttonTextTarget.textContent = "Compare Selected (2)"
    } else {
      this.compareButtonTarget.disabled = true
      if (count === 0) {
        this.buttonTextTarget.textContent = "Compare Selected"
      } else if (count === 1) {
        this.buttonTextTarget.textContent = `Select 1 more (${count}/2)`
      }
    }
  }
}
