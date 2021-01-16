var fs = require('fs');
console.log('building install file "install/create_console_objects.sql"');
fs.writeFileSync(
    'install/create_console_objects.sql',
    '--DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT src/build.js\n' +
    fs.readFileSync('src/install_template.sql', 'utf8')
        .replace('@set_ccflags.sql',  function () { return fs.readFileSync('src/set_ccflags.sql',  'utf8') })
        .replace('@CONSOLE_LOGS.sql', function () { return fs.readFileSync('src/CONSOLE_LOGS.sql', 'utf8') })
        .replace('@CONSOLE.pks',      function () { return fs.readFileSync('src/CONSOLE.pks',      'utf8') })
        .replace('@CONSOLE.pkb',      function () { return fs.readFileSync('src/CONSOLE.pkb',      'utf8') })
        .replace('@show_errors.sql',  function () { return fs.readFileSync('src/show_errors.sql',  'utf8') })
    /*
    Without the anonymous function call to fs.readFileSync we get wrong results, if
    we have a dollar signs in our package body text - the last answer explains it:
    https://stackoverflow.com/questions/9423722/string-replace-weird-behavior-when-using-dollar-sign-as-replacement
    */
);
