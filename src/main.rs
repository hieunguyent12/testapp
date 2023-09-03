use actix_files::NamedFile;
use actix_web::{get, web, App, HttpResponse, HttpServer, Responder};

// fn main() {
//     println!("Hi");
// }

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .service(index)
            .service(hello)
            .service(health_check)
    })
    .bind(("0.0.0.0", 8000))?
    .run()
    .await
}

#[get("/")]
async fn index() -> impl Responder {
    NamedFile::open_async("./dist/index.html").await.unwrap()
}

#[get("/health_check")]
async fn health_check() -> impl Responder {
    HttpResponse::Ok().finish()
}

#[get("/{name}")]
async fn hello(name: web::Path<String>) -> impl Responder {
    format!("Hello {}!", &name)
}
