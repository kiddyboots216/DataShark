import React from 'react';
import { Switch, Route } from 'react-router-dom';

import PrivateRoute from './utils/PrivateRoute';
import AuthRoute from './utils/AuthRoute';

import Home from './components/homePage';
import SignIn from './components/signin';
import SignUp from './components/signup';
import SignOut from './components/signout';
import Secret from './components/secret';
import NotFoundPage from './components/notFoundPage';


var Routes = () => (
  <Switch>
    <Route exact path="/" name="app" component={Home} />
    <AuthRoute path="/signin" name="signin" component={SignIn} />
    <AuthRoute path="/signup" name="signup" component={SignUp} />
    <Route path="/signout" name="signout" component={SignOut} />
    <PrivateRoute name="secret" path="/secret" component={Secret} />
    <Route component={NotFoundPage} />
  </Switch>
);

export default Routes;