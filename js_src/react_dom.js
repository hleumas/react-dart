const ReactDOM = require('react-dom');
const TestUtils = require('react-dom/test-utils');
const ShallowRenderer = require('react-test-renderer/shallow');

window.ReactTestUtils = TestUtils;
window.ShallowRenderer = ShallowRenderer;
window.ReactDOM = ReactDOM;