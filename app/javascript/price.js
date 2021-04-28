// window.addEventListener("load", function() {
//   const itemPrice = document.getElementById("item-price") //要素の取得 ✖️３
//   const addTax = document.getElementById("add-tax-price")
//   const profit = document.getElementById("profit")
//     // class名を使用すると、同じHTMLにて同じclass名の記載がある可能性がある。IDは1つだけだからIDを使用する。

    
//   itemPrice.addEventListener("keyup", function() {  //数値が入力された瞬間にイベント発火
//     const price = itemPrice.value                   //入力された数値を取得
//     addTax.innerHTML = Math.floor(price * 0.1)        //手数料計算(Mathオブジェクトを使って、小数点以下の表示がされないようにしている)
//     profit.innerHTML = price - addTax.innerHTML            //利益計算

//   })
// })

window.addEventListener("load", function() {
  const itemPrice = document.getElementById("item-price") //要素の取得 ✖️３
  const addTax = document.getElementById("add-tax-price")
  const profit = document.getElementById("profit")
    // class名を使用すると、同じHTMLにて同じclass名の記載がある可能性がある。IDは1つだけだからIDを使用する。

    
  itemPrice.addEventListener("keyup", function() {  //数値が入力された瞬間にイベント発火
    const price = itemPrice.value                   //入力された数値を取得
    const taxPrice = Math.floor(price * 0.1)        //手数料計算(Mathオブジェクトを使って、小数点以下の表示がされないようにしている)
    const profitPrice = price - taxPrice            //利益計算

    addTax.innerHTML = taxPrice                     //計算結果をビューに反映させる ✖️２
    profit.innerHTML = profitPrice
    // Math.floor(inputValue * 0.9)
  })
})

// // 見本コード
// window.addEventListener("DOMContentLoaded", () => {
//   const path = location.pathname
//   const pathRegex = /^(?=.*item)(?=.*edit)/
//   if (path === "/items/new" || path === "/items" || pathRegex.test(path)) {
//     //    出品ページの場合 || 出品ページの検証にかかった場合 || 商品編集の場合
//     const priceInput = document.getElementById("item-price");
//     const addTaxDom = document.getElementById("add-tax-price");
//     const profitDom = document.getElementById("profit");

//     priceInput.addEventListener("input", () => {
//       const inputValue = document.getElementById("item-price").value;
//         addTaxDom.innerHTML = Math.floor(inputValue * 0.1).toLocaleString();
//         profitDom.innerHTML = Math.floor(inputValue * 0.9).toLocaleString();
//     })
//   }
// });
