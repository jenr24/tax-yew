use yew::{function_component, html};

use wasm_bindgen::prelude::*;

#[function_component(App)]
fn app() -> Html {
    html! {
        <div>
            <h1> { "Hello Tax Yew!" } </h1>
        </div> 
    }
}

#[wasm_bindgen(start)]
pub fn run() {
    yew::start_app::<App>();
}