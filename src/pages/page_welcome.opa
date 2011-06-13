
server_welcome_static_page() =
  <>
    <h1>Welcome to this demo</h1>
    <p>This basic 3D tool will allow you to create a basic cubic scene. It is powered by:</p>
    <ul>
      <li><a href="http://www.opalang.org" >Opa</a></li>
      <li><a href="http://www.khronos.org/webgl/" >Webgl</a></li>
    </ul>
    <a href="scene/{Random.string(8)}" >&#8658; Create a new 3d scene</a>
  </> ;
