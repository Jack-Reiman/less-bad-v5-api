// Lightweight C++ Syntax Highlighter for Documentation Code Blocks
(function() {
  function highlightCpp(code) {
    const tokens = [];
    
    // Patterns
    const regex = /(\/\/[^\n]*|\/\*[\s\S]*?\*\/)|("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')|(\b(?:int32_t|uint32_t|int8_t|uint8_t|double|float|bool|void|char|size_t|std::string|vex::\w+|motor|drivetrain|smartdrive|brain|controller|inertial|optical|distance|rotation|gps|aivision|vision|pneumatics|bumper|limit|line|gyro|encoder|potentiometer|sonar|accelerometer|timer|competition|thread|event)\b)|(\b(?:true|false|NULL|nullptr|forward|reverse|fwd|rev|deg|degrees|turns|sec|seconds|msec|mseconds|pct|percent|rpm|dps|volt|volts|mV|PORT\d+|ratio\d+_\d+|coast|brake|hold)\b)|(\b(?:if|else|while|for|return|class|namespace|using|const|new|delete|switch|case|break|default|struct|enum|public|private|protected|static|virtual)\b)|(\b[a-zA-Z_]\w*(?=\s*\())|(\b\d+(?:\.\d+)?\b)|(::|->|[+\-*\/=<>!&|~^]+)|([{}()\[\];,])/g;

    let lastIndex = 0;
    let match;
    let out = '';

    while ((match = regex.exec(code)) !== null) {
      // plain text before match
      if (match.index > lastIndex) {
        out += escapeHtml(code.substring(lastIndex, match.index));
      }

      if (match[1]) {
        // Comment
        out += `<span class="token comment">${escapeHtml(match[1])}</span>`;
      } else if (match[2]) {
        // String / char
        out += `<span class="token string">${escapeHtml(match[2])}</span>`;
      } else if (match[3]) {
        // Type / Class
        out += `<span class="token type">${escapeHtml(match[3])}</span>`;
      } else if (match[4]) {
        // Constant / Enum value / Boolean
        out += `<span class="token constant">${escapeHtml(match[4])}</span>`;
      } else if (match[5]) {
        // Keyword
        out += `<span class="token keyword">${escapeHtml(match[5])}</span>`;
      } else if (match[6]) {
        // Function name
        out += `<span class="token function">${escapeHtml(match[6])}</span>`;
      } else if (match[7]) {
        // Number
        out += `<span class="token number">${escapeHtml(match[7])}</span>`;
      } else if (match[8]) {
        // Operator
        out += `<span class="token operator">${escapeHtml(match[8])}</span>`;
      } else if (match[9]) {
        // Punctuation
        out += `<span class="token punctuation">${escapeHtml(match[9])}</span>`;
      }

      lastIndex = regex.lastIndex;
    }

    if (lastIndex < code.length) {
      out += escapeHtml(code.substring(lastIndex));
    }

    return out;
  }

  function escapeHtml(s) {
    return (s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('pre code, pre.language-cpp').forEach(block => {
      // Don't re-highlight if already tokenized
      if (block.querySelector('.token')) return;
      block.innerHTML = highlightCpp(block.innerText);
    });
  });
})();
