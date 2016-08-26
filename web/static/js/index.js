// import React from 'react';
// import ReactDOM from 'react-dom';
// import Index from './containers';

// ReactDOM.render(<Index />, document.getElementById('index'));


import 'phoenix_html';
import Elm from '../elm/Index.elm';
Elm.Index.embed(document.getElementById('index'), window.APP_DATA);
