import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import SideNav from 'menu/SideNav';

const ICONS = {
    dashboard: 'fa-dashboard',
    finance: 'fa-money',
    statistics: 'fa-area-chart',
    calendar_events: 'fa-th',
    players: 'fa-users',
    settings: 'fa-cogs'
};

class GtMenu extends React.Component {
    static propTypes = {
        user: PropTypes.object,
        location: PropTypes.object
    };

    static contextTypes = {
        router: React.PropTypes.object.isRequired
    };

    constructor(props) {
        super(props);
        this.state = {
            selectedItem: null
        };
    }

    getSelectedItem() {
        for (let group of Object.keys(this.props.user.permissions)) {
            for (let item of Object.keys(this.props.user.permissions[group])) {
                if (this.isSelectedItem(this.getUrl(group, item))) {
                    return group == 'dashboard' ? 'dashboard' : item;
                }
            }
        }
    }

    componentWillMount() {
        this.setState({selectedItem: this.getSelectedItem()});
    }

    getUrl(block, node) {
        if (node == 'dashboard_index') {
            return '/';
        }
        return `/${block}/${node}`;
    }

    isSelectedItem(block) {
        return this.context.router.isActive(block) || (block == 'dashboard' && this.props.location.pathname == '/');
    }

    setSelectedItem(item) {
        this.setState({selectedItem: item.id});
    }

    getGroupChildren(block) {
        let parentBlock = this.props.user.permissions[block];
        let permissions = Object.keys(parentBlock).filter((node) => {
            return parentBlock[node].length > 0;
        });
        if (permissions.length < 2) {
            return [];
        }

        let navi = [];
        for (let node of permissions) {
            navi.push({
                id: node,
                text: node,
                url: this.getUrl(block, node)
            });
        }
        return navi;
    }

    render() {
        let permissions = Object.keys(this.props.user.permissions).filter((block) => {
            let parentBlock = this.props.user.permissions[block];
            let children = Object.keys(parentBlock).filter((node) => {
                return parentBlock[node].length > 0;
            });
            return children.length > 0;
        });

        let navi = [];
        for (let group of permissions) {
            if (group == 'dashboard') {
                navi.push({
                    id: group,
                    text: group,
                    icon: `fa ${ICONS[group]}`,
                    url: this.getUrl(group, 'dashboard_index'),
                    navlist: this.getGroupChildren(group)
                });
            } else {
                navi.push({
                    id: group,
                    text: group,
                    icon: `fa ${ICONS[group]}`,
                    navlist: this.getGroupChildren(group)
                });
            }
        }

        return (
            <SideNav
                navs={navi}
                selected={this.state.selectedItem}
                style={{overflow: 'hidden'}}
                onSelection={this.setSelectedItem.bind(this)}
            />
        );
    }
}

const mapStateToProps = (state) => {
    return state.auth;
};

export default connect(mapStateToProps)(GtMenu);
