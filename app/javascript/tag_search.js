window.addEventListener("DOMContentLoaded", () => {
  // タグの入力欄を取得
  const tagNameInput = document.getElementById("tag-name-form");
  // タグの入力欄がないなら実行せずここで終了
  if (!tagNameInput) return null;
  
  tagNameInput.addEventListener("input", () => {
    const tagValue = tagNameInput.value;
    // console.log(tagValue);
    
    const XHR = new XMLHttpRequest();
    // params[:tag_name]に変数tagValueを送る
    XHR.open("GET", `/items/tag_search/?tag_name=${tagValue}`, true);
    XHR.responseType = "json";
    XHR.send();

    XHR.onload = () => {
      const tagName = XHR.response.keyword;
      // console.log(tagName);
      const searchResult = document.getElementById("tag-search-result");

      // 入力した文字を消す度に検索結果が表示されることを防ぐ
      searchResult.innerHTML = "";   
      searchResult.setAttribute("style", "");

      tagName.forEach((tag) => {
        const childElement = document.createElement("div");
        childElement.setAttribute("class", "child");
        childElement.setAttribute("id", tag.id);
        childElement.innerHTML = tag.name;
        searchResult.appendChild(childElement);
        // クリックしたらクリックした単語を削除する
        const clickElement = document.getElementById(tag.id);
         clickElement.addEventListener("click", () => {
           tagNameInput.value = clickElement.textContent;
           clickElement.remove(); //クリックした単語だけ消える
           // クリックしたときに、検索結果全てを消す場合は下の記述
           // searchResult.setAttribute("style", "");
           // searchResult.innerHTML = "";
         });
      });
    };


  });
});
