import getMuiTheme from 'material-ui/styles/getMuiTheme';
import {fullWhite, indigo500, indigo700, pinkA200, indigo900, indigo50} from 'material-ui/styles/colors';
import spacing from 'material-ui/styles/spacing';
import typography from 'material-ui/styles/typography';
import lightTheme from 'material-ui/styles/baseThemes/lightBaseTheme';

class Indigo {
    constructor() {
        this._theme = null;
    }

    create(userAgent) {
        this._theme = getMuiTheme({
            userAgent: userAgent,
            palette: {
                primary1Color: indigo500,
                primary2Color: indigo700
            },
            toolbar: {
                backgroundColor: indigo500
            },
            drawer: {
                selectedColor: pinkA200,
                selectedIcon: fullWhite
            },
            title: {
                fontSize: typography.fontStyleButtonFontSize * 2,
                fontFamily: lightTheme.fontFamily,
                color: indigo900,
                marginTop: 0
            },
            link: {
                cursor: 'pointer'
            },
            table: {
                width: '100%'
            },
            tableHeaderColumn: {
                height: 48,
                spacing: 8
            },
            tableRow: {
                height: 32
            },
            tableRowColumn: {
                height: 32,
                spacing: 8
            },
            padding: {
                md: spacing.desktopGutterLess,
                sm: spacing.desktopGutterMini
            },
            tabs: {
                backgroundColor: indigo50
            },
            tab: {
                color: indigo900
            }
        });
    }

    get theme() {
        return this._theme;
    }
}

export default new Indigo();
