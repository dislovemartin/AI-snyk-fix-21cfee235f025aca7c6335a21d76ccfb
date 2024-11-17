
use actix_web::{post, web, App, HttpServer, Responder};
use serde::Deserialize;

#[derive(Deserialize)]
struct TextInput {
    input_text: String,
}

#[post("/process_text")]
async fn process_text(data: web::Json<TextInput>) -> impl Responder {
    let output_text = data.input_text.to_uppercase(); // Placeholder for processing
    web::Json(output_text)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| App::new().service(process_text))
        .bind("0.0.0.0:8081")?
        .run()
        .await
}
