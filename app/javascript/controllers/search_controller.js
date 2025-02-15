import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "results"]
  
  initialize() {
    this.submit = this.debounce(this.submit.bind(this), 100)
  }
  
  search(event) {
    // Don't prevent default here to allow normal form submission as backup
    this.submit()
  }

  submit() {
    const form = this.formTarget
    const url = new URL(form.action)
    const formData = new FormData(form)
    
    // Append form data to URL
    for (const [key, value] of formData.entries()) {
      url.searchParams.append(key, value)
    }
    
    fetch(url, {
      headers: {
        "Accept": "text/html, application/xhtml+xml",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
    .then(response => response.text())
    .then(html => {
      this.resultsTarget.innerHTML = html
    })
    .catch(error => {
      console.error('Error:', error)
    })
  }
  
  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }
}