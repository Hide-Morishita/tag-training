// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
// require("turbolinks").start()
// 上記、コメントアウトしてるのは、ページ遷移したときにHTMLを高速で読み込む。bodyだけが高速で読み込まれるからJS動かなくなる。
require("@rails/activestorage").start()
require("channels")
require("../price");
require("../create_token");
require("../tag_search");

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
