/**
 * BaseCell class for handling code execution using Pyodide.
 * @class
 */
class BaseCell {
    /**
     * Constructor for BaseCell.
     * @constructor
     * @param {Object} cellData - JSON object containing code, id, and options.
     * @param {Object} pyodideEngine - Instance of pyodide.
     */
    constructor(cellData, pyodideEngine) {
        this.code = cellData.code;
        this.id = cellData.id;
        this.options = cellData.options;
        
        // Handle initializing of an async variable
        this.pyodide = null;
        initializeAsyncPyodide(pyodideEngine);
    }

    /**
     * Set up Pyodide for code execution.
     */
    async initializeAsyncPyodide(promise) {
        // Ensure Pyodide is initialized for code execution
        try {
            // Wait for the promise to resolve
            this.pyodide = await promise;
        } catch (error) {
            console.error('Error during initialization:', error);
        }
    }

    cellOptions() {
        // Subclass this? 
        console.log(this.options);
        return this.options;
    }

    /**
     * Execute the Python code using Pyodide.
     * @returns {*} Result of the code execution.
     */
    executeCode() {
        // Execute code using Pyodide
        const result = this.pyodide.runPython(this.code);
        return result;
    }
};

/**
 * InteractiveCell class for creating editable code editor with Monaco Editor.
 * @class
 * @extends BaseCell
 */
class InteractiveCell extends BaseCell {

    /**
     * Constructor for InteractiveCell.
     * @constructor
     * @param {Object} cellData - JSON object containing code, id, and options.
     * @param {Object} pyodideEngine - Instance of pyodide.
     */
    constructor(cellData, pyodideEngine) {
        super(cellData, pyodideEngine);
        this.editor = null;
        this.setupMonacoEditor();
        this.setupRunButton();
    }

    /**
     * Set up Monaco Editor for code editing.
     */
    setupMonacoEditor() {
        // Initialize Monaco Editor and set up code editor environment
        this.editor = monaco.editor.create(
            document.getElementById(this.id),
            {
                value: this.code, language: 'python' 
            }
        );
    }

    /**
     * Set up "Run code" button and attach event listener to execute the code.
     */
    setupRunButton() {
        // Create a run code button for the editor instance
        const runButton = document.createElement('button');
        runButton.textContent = 'Run code';
        runButton.addEventListener('click', () => this.runCode());
        document.getElementById(this.id).appendChild(runButton);
    }

    /**
     * Execute the Python code inside the editor.
     */
    runCode() {
        // Extract code
        const code = this.editor.getValue();
        // Obtain results from the base class
        const result = this.executeCode(code);
    }
};

/**
 * OutputCell class for customizing and displaying output.
 * @class
 * @extends BaseCell
 */
class OutputCell extends BaseCell {
    /**
     * Constructor for OutputCell.
     * @constructor
     * @param {Object} cellData - JSON object containing code, id, and options.
     * @param {Object} pyodideEngine - Instance of pyodide.
     */
    constructor(cellData, pyodideEngine) {
      super(cellData, pyodideEngine);
    }
  
    /**
     * Display customized output on the page.
     * @param {*} output - Result to be displayed.
     */
    displayOutput(output) {
        const results = this.executeCode();
        return results;
    }
  }

/**
 * SetupCell class for suppressed output.
 * @class
 * @extends BaseCell
 */
class SetupCell extends BaseCell {
    /**
     * Constructor for SetupCell.
     * @constructor
     * @param {Object} cellData - JSON object containing code, id, and options.
     * @param {Object} pyodideEngine - Instance of pyodide.
     */
    constructor(cellData, pyodideEngine) {
        super(cellData, pyodideEngine);
    }

    /**
     * Execute the Python code without displaying the results.
     */
    runSetupCode() {
        // Execute code without displaying output
        this.executeCode();
    }
};