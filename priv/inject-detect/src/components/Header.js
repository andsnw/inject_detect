import AddApplicationModal from './AddApplicationModal';
import React from 'react';
import SignOutLink from './SignOutLink';
import _ from 'lodash';
import { Link, NavLink } from 'react-router-dom';
import { Redirect } from 'react-router-dom';
import { UserQuery } from '../graphql';
import { graphql } from 'react-apollo';

class Header extends React.Component {
    state = {
        redirect: false
    };

    initDropdown() {
        window.$('.ui.dropdown').dropdown();
    }

    componentDidMount() {
        this.initDropdown();
    }

    componentDidUpdate() {
        this.initDropdown();
    }

    showAddApplicationModal(e) {
        e.preventDefault();
        window.$('.ui.add-application-modal.modal').modal('show');
    }

    onSignOut = () => {
        this.setState({ redirect: true });
    };

    render() {
        let { user } = this.props.data;

        if (user) {
            return (
                <div className="ui stackable menu ij-header">
                    {this.state.redirect ? <Redirect to="/" /> : null}
                    <div className="ui container">
                        <Link to="/" className="header borderless item">
                            <img
                                alt="Inject Detect Logo"
                                src="https://s3.amazonaws.com/www.injectdetect.com/logo.png"
                                className="icon"
                            />
                            Inject Detect
                        </Link>

                        <NavLink to="/" exact={true} className="borderless item">Dashboard</NavLink>

                        <div className="ui simple dropdown borderless item">
                            Applications <i className="dropdown icon" />
                            <div className="menu">

                                {user &&
                                    user.applications &&
                                    user.applications.map(application => {
                                        return (
                                            <Link
                                                to={`/application/${application.id}`}
                                                key={application.id}
                                                className="item"
                                            >
                                                <i className="server outline icon" />{application.name}
                                            </Link>
                                        );
                                    })}

                                <AddApplicationModal user={user} />
                            </div>
                        </div>

                        <div className="right menu">
                            <div className="borderless item">
                                <button id="userbutton" className="ui right labeled icon brand dropdown button">
                                    <i className="caret down icon" />
                                    {user.email}
                                    <div className="menu">
                                        <Link to="/account" className="item">
                                            <i className="settings icon" />
                                            Account settings
                                        </Link>
                                        <div className="divider" />
                                        <SignOutLink onSignOut={this.onSignOut}>
                                            <i className="sign out icon" />
                                            Sign out
                                        </SignOutLink>
                                    </div>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            );
        } else {
            return (
                <div className="ui menu ij-header">
                    {this.state.redirect ? <Redirect to="/" /> : null}
                    <div className="ui container">
                        <Link to="/" className="header borderless item">
                            <img
                                alt="Inject Detect Logo"
                                src="https://s3.amazonaws.com/www.injectdetect.com/logo.png"
                                className="icon"
                            />
                            Inject Detect
                        </Link>

                        <div className="right menu">
                            <div className="borderless item">
                                <Link to="/sign-in" className="ui right brand button">
                                    Sign in
                                </Link>
                            </div>
                        </div>
                    </div>
                </div>
            );
        }
    }
}

export default graphql(UserQuery, {
    options({ params }) {
        return {
            reducer: (previousResults, action) => {
                switch (action.operationName) {
                    case 'verifyRequestedToken':
                        return _.extend({}, previousResults, {
                            user: _.get(action, 'result.data.verifyRequestedToken')
                        });
                    case 'getStarted':
                        return _.extend({}, previousResults, {
                            user: _.get(action, 'result.data.getStarted')
                        });
                    case 'signOut':
                        return _.extend({}, previousResults, {
                            user: null
                        });
                    default:
                        return previousResults;
                }
            }
        };
    }
})(Header);
