const bcrypt = require('bcryptjs');
const hash = '$2a$10$X1j18H1P0.oB/A3P7G46JupJvD5B5n5mPzRYF/s08qG5x6v9G9NRO';
const pass = '123456';

bcrypt.compare(pass, hash).then(res => {
    console.log('Result for 123456:', res);
});
