# Pin npm packages by running ./bin/importmap
pin "application" # look in app/javascript/application.js or vendor/javascript/application.js
pin "@hotwired/turbo-rails", to: "turbo.min.js" # imported in main application file: app/javascript/application.js
pin "@hotwired/stimulus", to: "stimulus.min.js" # imported in app/javascript/application.js
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js" # imported in app/javascript/controllers/index.js

pin_all_from "app/javascript/controllers", under: "controllers"
