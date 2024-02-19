// Create a logging setup
globalThis.qpyodideMessageArray = []

// Add messages to array
globalThis.qpyodideAddToOutputArray = function(message, type) {
  qpyodideMessageArray.push({ message, type });
}

// Function to reset the output array
globalThis.qpyodideResetOutputArray = function() {
  qpyodideMessageArray = [];
}

globalThis.qpyodideRetrieveOutput = function() {
  return qpyodideMessageArray.map(entry => entry.message).join('\n');
}

// Start a timer
const initializePyodideTimerStart = performance.now();

// Encase with a dynamic import statement
globalThis.qpyodideInstance = await import(
  qpyodideCustomizedPyodideOptions.indexURL + "pyodide.mjs").then(
   async({ loadPyodide }) => {

    console.log("Start loading Pyodide");
    
    // Populate Pyodide options with defaults or new values based on `pyodide`` meta
    let mainPyodide = await loadPyodide(
      qpyodideCustomizedPyodideOptions
    );
    
    // Setup a namespace for global scoping
    // await loadedPyodide.runPythonAsync("globalScope = {}"); 

    // Add matplotlib
    await mainPyodide.loadPackage("matplotlib");

    // Set the backend for matplotlib to be interactive.
    await mainPyodide.runPythonAsync(`
    import matplotlib
    matplotlib.use("module://matplotlib_pyodide.html5_canvas_backend")
    from matplotlib import pyplot as plt
    `);

    // Unlock interactive buttons
    qpyodideSetInteractiveButtonState(
      `<i class="fa-solid fa-play qpyodide-icon-run-code"></i> <span>Run Code</span>`, 
      true
    ); 

    if (qpyodideShowStartupMessage) {
      qpyodideStartupMessage.innerText = "🟢 Ready!"
    }

    // Assign Pyodide into the global environment
    globalThis.mainPyodide = mainPyodide;

    console.log("Completed loading Pyodide");
    return mainPyodide;
  }
);

// Stop timer
const initializePyodideTimerEnd = performance.now();

// Create a function to retrieve the promise object.
globalThis._qpyodideGetInstance = function() {
    return qpyodideInstance;
}
