import 'phoenix_html';
import Elm from './Main.elm';

var app = Elm.Main.fullscreen();
app.ports.loggedUser.send(window.APP_DATA.auth.user);
