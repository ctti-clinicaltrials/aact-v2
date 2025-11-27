import { Controller } from "@hotwired/stimulus"

// A simple multi-select dropdown with tags - ~80 lines vs ~1700 lines for Tom Select
export default class extends Controller {
  static targets = ["input", "dropdown", "tags", "search"]
  static values = {
    options: Array,
    selected: { type: Array, default: [] },
    placeholder: { type: String, default: "Select..." },
    name: String,
    submitOnChange: { type: Boolean, default: false }
  }

  connect() {
    this.selectedValue = [...this.selectedValue]
    this.render()
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
  }

  handleClickOutside = (event) => {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  toggle() {
    this.dropdownTarget.classList.toggle("hidden")
    if (!this.dropdownTarget.classList.contains("hidden")) {
      this.searchTarget?.focus()
    }
  }

  close() {
    this.dropdownTarget.classList.add("hidden")
  }

  select(event) {
    const value = event.currentTarget.dataset.value
    if (!this.selectedValue.includes(value)) {
      this.selectedValue = [...this.selectedValue, value]
      this.render()
      this.maybeSubmit()
    }
  }

  remove(event) {
    event.stopPropagation()
    const value = event.currentTarget.dataset.value
    this.selectedValue = this.selectedValue.filter(v => v !== value)
    this.render()
    this.maybeSubmit()
  }

  filter(event) {
    const query = event.target.value.toLowerCase()
    this.element.querySelectorAll("[data-option]").forEach(option => {
      const text = option.textContent.toLowerCase()
      option.classList.toggle("hidden", !text.includes(query))
    })
  }

  maybeSubmit() {
    if (this.submitOnChangeValue) {
      const form = this.element.closest("form")
      if (form) form.requestSubmit()
    }
  }

  render() {
    // Render tags
    this.tagsTarget.innerHTML = this.selectedValue.length === 0
      ? `<span class="text-gray-500">${this.placeholderValue}</span>`
      : this.selectedValue.map(value => `
          <span class="inline-flex items-center gap-1 px-2 py-1 text-sm bg-blue-100 text-blue-800 rounded">
            ${value}
            <button type="button" data-action="multiselect#remove" data-value="${value}" class="hover:text-blue-600">
              <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </span>
        `).join("")

    // Update hidden inputs
    this.inputTarget.innerHTML = this.selectedValue.map(value =>
      `<input type="hidden" name="${this.nameValue}" value="${value}">`
    ).join("")

    // Update dropdown options (mark selected)
    this.element.querySelectorAll("[data-option]").forEach(option => {
      const isSelected = this.selectedValue.includes(option.dataset.value)
      option.classList.toggle("bg-blue-50", isSelected)
      option.classList.toggle("text-blue-700", isSelected)
    })
  }
}
