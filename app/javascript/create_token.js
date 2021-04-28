window.addEventListener("DOMContentLoaded", () => {

  // 読み込まれたらイベント発火
  const path = location.pathname
  const params = path.replace(/items/g, '').replace(/transactions/g, '').replace(/\//g, '');

  if (path.includes("items") && path.includes("transactions") && /^([1-9]\d*|0)$/.test(params)) {
    const PAYJP_PK = process.env.PAYJP_PUBLIC_KEY
    Payjp.setPublicKey(PAYJP_PK);
    const form = document.getElementById("charge-form");

    form.addEventListener("submit", (e) => {
      e.preventDefault();
      const sendWithoutCardInfo = () => {
        document.getElementById("card-number").removeAttribute("name");
        document.getElementById("card-cvc").removeAttribute("name");
        document.getElementById("card-exp-month").removeAttribute("name");
        document.getElementById("card-exp-year").removeAttribute("name");
        // 以下を使用して購入ボタン押したら動くように実装。これを止めると購入ボタン押しても動かない
        document.getElementById("charge-form").submit();
        document.getElementById("charge-form").reset();
      }
      const formResult = document.getElementById("charge-form");
      const formData = new FormData(formResult);

      // カード情報の構成や、トークン生成はこちらのリファレンスを参照
// ここが取れてない人多い
      // https://pay.jp/docs/payjs-v1
      const card = {
        number: formData.get("pay_form[number]"),
        cvc: formData.get("pay_form[cvc]"),
        exp_month: formData.get("pay_form[exp_month]"),
        exp_year: `20${formData.get("pay_form[exp_year]")}`,
      };
      // console.log(card)を使用して情報が取得できているか確認

      Payjp.createToken(card, (status, response) => {
        // カード情報が送られているかconsole.log(status)入れて確認
        if (status === 200) {
          // response.idでtokenが取得できます。
          const token = response.id;
          // console.log(token)でtokenが取得できているか確認する
          const renderDom = document.getElementById("charge-form");
          // サーバーにトークン情報を送信するために、inputタグをhidden状態で追加する。
          const tokenObj = `<input value=${token} type="hidden" name='token'>`;
          renderDom.insertAdjacentHTML("beforeend", tokenObj);
          sendWithoutCardInfo()
        } else {
          // window.alert('購入処理に失敗しました。\nお手数ですが最初からやり直してください。');
          sendWithoutCardInfo()
        }
      });
    });
  }
});
