var React = require('react-native');
var {
  requireNativeComponent,
  PropTypes
} = React;

class WKWebView extends React.Component {
  render() {
    return <AQWebView {...this.props} />;
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

  onLoadingStart: PropTypes.func,
  onLoadingFinish: PropTypes.func,
  onLoadingError: PropTypes.func,

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
