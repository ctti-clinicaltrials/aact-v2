// Vendor code for stimulus-loading as provided by Rails

function eagerLoadControllersFrom(under, application) {
  const paths = Object.keys(parseImportmapJson()).filter(path => path.match(new RegExp(`^${under}/.*_controller$`)))
  paths.forEach(path => registerControllerFromPath(path, under, application))
}

function lazyLoadControllersFrom(under, application) {
  const paths = Object.keys(parseImportmapJson()).filter(path => path.match(new RegExp(`^${under}/.*_controller$`)))
  paths.forEach(path => registerControllerFromPath(path, under, application))
}

function parseImportmapJson() {
  return JSON.parse(document.querySelector("script[type=importmap]").textContent).imports
}

function registerControllerFromPath(path, under, application) {
  const name = path
    .replace(new RegExp(`^${under}/`), "")
    .replace("_controller", "")
    .replace(/\//g, "--")
    .replace(/_/g, "-")

  if (canRegisterController(name, path, under)) {
    import(path).then(module => application.register(name, module.default))
  }
}

function canRegisterController(name, path, under) {
  return !application.router.modulesByIdentifier.has(name)
}

export { eagerLoadControllersFrom, lazyLoadControllersFrom }