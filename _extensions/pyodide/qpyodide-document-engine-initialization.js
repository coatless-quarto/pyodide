// Start a timer
const initializeWebRTimerStart = performance.now();
  

// Encase with a dynamic import statement
globalThis.qpyodideInstance = await import(
  qpyodideCustomizedPyodideOptions.indexURL + "pyodide.mjs").then(
   async({ loadPyodide }) => {

    console.log("Start loading Pyodide");
    // Populate Pyodide options with defaults or new values based on `pyodide`` meta
    let loadedPyodide = await loadPyodide(
      qpyodideCustomizedPyodideOptions
    );
    
    loadedPyodide.runPython("globalScope = {}");

    globalThis.mainPyodide = loadedPyodide;
    
    console.log("Completed loading Pyodide");
    return loadedPyodide;
  }
);

// Stop timer
const initializeWebRTimerEnd = performance.now();

// Create a function to retrieve the promise object.
globalThis._qpyodideGetInstance = function() {
    return qpyodideInstance;
}
