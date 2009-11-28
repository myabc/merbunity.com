{
   _name: "java"
 , _case: true
 , _main: {
   mlcom : {
    _match  : /#[^\n]+/,
    _style  : "color: #444444;"
   },
   brackets : {
    _match  : /\(|\)/,
   },
   string : {
    _match  : /'[^']*'|"[^"]*"/,
    _style  : "color: #BD48B3;"
   },
   keyword : {
    _match  : /\b(do|end|self|class|def|if|module|yield|then|else|for|until|unless|while|elsif|case|when|break|retry|redo|rescue|require|raise)\b/,
    _style  : "color: #FF8400;"
   },
   method : {
    _match  : /\b(attr|attr_reader|attr_accessor|attr_writer)\b/,
    _style  : "color: rgb(75,181,20);"
   },
   symbol   : {
    _match  : /([^:])(:[A-Za-z0-9_!?]+)/,
      _style  : "color: #6BCFF7"
   }
 }
}
