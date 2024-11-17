
package ai.scala

import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.http.scaladsl.server.Directives._
import akka.stream.ActorMaterializer
import scala.io.StdIn

object ScalaService {
  def main(args: Array[String]): Unit = {
    implicit val system = ActorSystem("scalaService")
    implicit val materializer = ActorMaterializer()
    implicit val executionContext = system.dispatcher

    val route = path("process_data") {
      post {
        entity(as[String]) { inputData =>
          complete(inputData.reverse) // Example placeholder for processing
        }
      }
    }

    val bindingFuture = Http().bindAndHandle(route, "0.0.0.0", 8080)
    println(s"Server online at http://0.0.0.0:8080/")
    StdIn.readLine()
    bindingFuture
      .flatMap(_.unbind())
      .onComplete(_ => system.terminate())
  }
}
