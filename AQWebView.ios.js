var React = require('react-native');
var {
  requireNativeComponent,
  PropTypes,
  NativeModules
} = React;

class WKWebView extends React.Component {

  goBack() {
    NativeModules.AQWebViewManager.goBack(React.findNodeHandle(this.refs.AQWebView);
  }

  goForward() {
    NativeModules.AQWebViewManager.goForward(React.findNodeHandle(this.refs.AQWebView);
  }

  _onLoadingStart(navState) {
    if (this.props.onNavigationStateChange) {
      this.props.onNavigationStateChange({type: 'start', ...navState.nativeEvent});
    }
  }

  _onLoadingEnd(navState) {
    if (this.props.onNavigationStateChange) {
      this.props.onNavigationStateChange({type: 'end', ...navState.nativeEvent});
    }
  }
  
  _onLoadingError(navState) {
    if (this.props.onNavigationStateChange) {
      this.props.onNavigationStateChange({type: 'error', ...navState.nativeEvent});
    }
  }

  render() {
    return <AQWebView ref="AQWebView" 
                      {...this.props} 
                      onLoadingStart={this._onLoadingStart.bind(this)}
		      onLoadingEnd={this._onLoadingEnd.bind(this)}
		      onLoadingError={this._onLoadingError.bind(this)}
	    />;
  }

}

WKWebView.propTypes = {
  source: PropTypes.oneOfType([
    PropTypes.shape({
      uri: PropTypes.string,
      method: PropTypes.string,
      headers: PropTypes.object,
      body: PropTypes.string,
    }),
    PropTypes.shape({
      html: PropTypes.string,
      baseUrl: PropTypes.string,
    }),
  ]),

  onNavigationStateChange: PropTypes.func,

  automaticallyAdjustContentInsets: PropTypes.bool,
  contentInset: PropTypes.shape({
    top: PropTypes.number,
    left: PropTypes.number,
    bottom: PropTypes.number,
    right: PropTypes.number
  }),

  blockedPrefixes: PropTypes.arrayOf(PropTypes.string),
  onPrefixBlocked: PropTypes.func,
};

var AQWebView = requireNativeComponent('AQWebView', WKWebView);

module.exports = WKWebView;
