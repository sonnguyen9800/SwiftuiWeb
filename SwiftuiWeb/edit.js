var richeditor = {};
var editor = document.getElementById("editor");

richeditor.insertText = function(text) {
    editor.innerHTML = text;
    window.webkit.messageHandlers.heightDidChange.postMessage(document.body.offsetHeight);
}

editor.addEventListener("input", function() {
    window.webkit.messageHandlers.textDidChange.postMessage(editor.innerHTML);
}, false)

document.addEventListener("selectionchange", function() {
    window.webkit.messageHandlers.heightDidChange.postMessage(document.body.offsetHeight);
}, false);

function getToolbarState() {
  return {
    foreColor: RGBToHex(document.queryCommandValue("ForeColor")),
    backColor: getBackColor() || document.queryCommandValue("backcolor"),
    bold: document.queryCommandState("bold"),
    italic: document.queryCommandState("italic"),
    fontName: document.queryCommandValue("fontName"),
    fontSize: document.queryCommandValue("fontSize"),
    underline: document.queryCommandState("Underline"),
    strikeThrough: document.queryCommandState("strikeThrough"),
    insertunorderedlist: document.queryCommandState("insertunorderedlist"),
    insertorderedlist: document.queryCommandState("insertorderedlist"),
    justifyleft: document.queryCommandState("justifyleft"),
    justifycenter: document.queryCommandState("justifycenter"),
    justifyright: document.queryCommandState("justifyright"),
  };
}

function getBackColor() {
  var node = document.getSelection().focusNode;
  var editor = document.getElementById('editor');
  var isNonDefault = function(c) { return c && c !== 'transparent';}

  // If TEXTNODE set to parentNode
  if (node.nodeType == 3) {
    node = node.parentNode;
  }

  while (node && node !== editor) {
    var tempColor = node.style && node.style.backgroundColor;

    if (isNonDefault(tempColor)) {
      return tempColor;
    }

    node = node.parentNode;
  }

  return 'transparent';
}

function focusEditor() {
  document.getElementById('editor').focus();
}

function updateToolbar() {
  var editor = document.getElementById('editor');
  var focusNode = document.getSelection().focusNode;

  if (!editor.contains(focusNode)) {
    return;
  }

  var state = getToolbarState();
  
  log(state);
  updateButtonState(state);
}

function updatePopupValue(key, value) {
  var activeBtn = document.querySelector('#' + key + ' button.active');
  var btn = document.querySelector('#' + key +'  [data-value="' + value + '"]');

  if (!btn) {
    return;
  }

  if (activeBtn) {
    activeBtn.classList.remove('active');
  }

  btn.classList.add('active');
}

function updateButtonState(config) {
  Object.keys(config).forEach(k => {

    if (k == 'foreColor' || k == 'backColor') {

      updatePopupValue(k, config[k]);

      return;
    }

    var el = document.querySelector('[data-action="' + k + '"]');

    if (!el) {
      return;
    }

    if (el.tagName == 'SELECT') {
      el.value = config[k];
    }

    if (config[k] == true) {
      el.classList.add('active');
    } else {
      el.classList.remove('active');
    }
  });
}

function RGBToHex(rgb) {
  if (!rgb || rgb.indexOf('rgb(') < 0) {
    return rgb;
  }

  var sep = rgb.indexOf(",") > -1 ? "," : " ";
  var colors = rgb.substr(4).split(")")[0].split(sep);
  var r = (+colors[0]).toString(16);
  var g = (+colors[1]).toString(16);
  var b = (+colors[2]).toString(16);

  r = `0${r}`.slice(-2);
  g = `0${g}`.slice(-2);
  b = `0${b}`.slice(-2);

  return "#" + r + g + b;
}

function onAction(e) {
  var value = null;
  var target = e.target;
  
  if (target.tagName != 'BUTTON') {

    return;
  }

  var action = target.getAttribute('data-action');

  if (action == 'foreColor' || action == "backColor") {
    value = target.getAttribute('data-value');
  }
 
     document.execCommand(action, false, value);

  updateToolbar();
  focusEditor();
}

function onChange(e) {
  var value = e.target.value;
  var action = e.target.getAttribute('data-action');

  document.execCommand(action, false, value);

  updateToolbar();
  focusEditor();
}

function bindEventHandlers() {
  var toolbar = document.getElementById('toolbar');
  var dropDowns = [].slice.call(document.getElementsByTagName('select'));

  toolbar.addEventListener("click", onAction);
  dropDowns.forEach(d => d.addEventListener("change", onChange));
  document.addEventListener("selectionchange", updateToolbar);
}

function initForeColor() {
  var colors = [
    "#9d1811",
    "#e4ac64",
    "#5b8828",
    "#440062",
    "#ffffff",
    "#000000"
  ];
  var foreColor = document.getElementById('foreColor');
  var fragment = document.createDocumentFragment();

  colors.forEach(color => {
    var li = document.createElement('li');
    var btn = document.createElement('button');

    btn.style.backgroundColor = color;
    btn.setAttribute("data-action", "foreColor");
    btn.setAttribute("data-value", color);

    if (color === '#ffffff') {
      btn.setAttribute('data-color', 'white');
    }

    li.appendChild(btn);
    fragment.appendChild(li);
  });

  foreColor.appendChild(fragment);
}

function initBackColor() {
  var colors = [
    "rgb(157, 24, 17)",
    "rgb(164, 96, 22)",
    "rgb(91, 136, 40)",
    "rgb(253, 239, 43)",
    "rgb(112, 172, 237)",
    "rgb(255, 255, 255)",
  ];
  var foreColor = document.getElementById('backColor');
  var fragment = document.createDocumentFragment();

  colors.forEach(color => {
    var li = document.createElement('li');
    var btn = document.createElement('button');

    btn.style.backgroundColor = color;
    btn.setAttribute("data-value", color);
    btn.setAttribute("data-action", "backColor");

    if (color === 'rgb(255, 255, 255)') {
      btn.setAttribute('data-color', 'white');
    }

    li.appendChild(btn);
    fragment.appendChild(li);
  });

  foreColor.appendChild(fragment);
}

function log(state) {
  var output = "<pre>{" + "\n"
  var debug = document.getElementById("debug");

  Object.keys(state).forEach(function(k) {
      output += '' + k + ':' + state[k] + ', \n';
  });

  output += "}</pre>";

  debug.innerHTML = output;
}

function init() {
  initForeColor();
  initBackColor();
  bindEventHandlers();

  document.body.style.fontSize = 7;
  document.body.style.fontFamily = '"Helvetica Neue",  Helvetica, Arial, sans-serif';
}

init();

