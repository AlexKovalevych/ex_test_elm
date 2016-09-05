import 'phoenix_html';
import Elm from './Main.elm';

var app = Elm.Main.fullscreen();
if (window.APP_DATA.auth) {
    app.ports.loggedUser.send(window.APP_DATA.auth.user);
}
