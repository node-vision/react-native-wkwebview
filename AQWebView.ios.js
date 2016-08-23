var React = require('react');
var {
  PropTypes,
} = React;
var ReactNative = require('react-native');
var {
  requireNativeComponent,
  NativeModules
} = ReactNative;

var AQWebView = requireNativeComponent('AQWebView', WKWebView);

class WKWebView extends React.Component {

  goBack() {
    NativeModules.AQWebViewManager.goBack(React.findNodeHandle(this.refs.AQWebView));
  }

  goForward() {
    NativeModules.AQWebViewManager.goForward(React.findNodeHandle(this.refs.AQWebView));
  }

  getNavigationState(callback) {
    NativeModules.AQWebViewManager.baseEvent(React.findNodeHandle(this.refs.AQWebView), (err, res) => {
      if (err) {
        callback('Getting navigation state from webview error: ' + err)
      }
      else {
        callback(null, res)
      }
    })
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
                      onLoadingFinish={this._onLoadingEnd.bind(this)}
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
      body: PropTypes.string
    }),
    PropTypes.shape({
      html: PropTypes.string,
      baseUrl: PropTypes.string
    })
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
  onPrefixBlocked: PropTypes.func
};

module.exports = WKWebView;
