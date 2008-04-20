{ steps: {
		mlcom : {
			exp  : /#[^\n]+/
		},
		brackets : {
			exp  : /\(|\)/
		},
		string : {
			exp  : /'[^']*'|"[^"]*"/
		},
		keyword : {
			exp  : /\b(do|end|self|class|def|if|module|yield|then|else|for|until|unless|while|elsif|case|when|break|retry|redo|rescue|require|raise)\b/
		},
		method : {
			exp  : /\b(attr|attr_reader|attr_accessor|attr_writer)\b/
		},
		symbol   : {
			exp  : /([^:])(:[A-Za-z0-9_!?]+)/,
	    replacement : "$1<span class=\"$0\">$2</span>"
		}
	}
}