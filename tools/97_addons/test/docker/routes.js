const express = require('express');
const bodyParser = require('body-parser');
const processing = require("./processing.js");

const router = express.Router();

const token = process.env.TOKEN || ""

global.token = ""
global.loggedin = false


//**************************************************************************************************
// Basic Functions
//**************************************************************************************************
function render_with_token(req, res, page, parameters) {
  if (global.loggedin == true) {
    res.render(page, parameters);
  } else {
    res.render('login', {});
  }
}

router.get("/init", function (req, res) {
  git_init();
});



//**************************************************************************************************
// Basic Paths
//**************************************************************************************************
router.get("/", function (req, res) {
  render_with_token(req, res, 'index', {});
});


router.get("/login", function (req, res) {
  //global.loggedin = true
  if (req.query.token == token) {
    global.loggedin = true
    console.log("   ✅ LOGGED IN", req.query);
    render_with_token(req, res, 'index', {});
  } else {
    global.loggedin = false
    console.log("   ❌ LOGIN REFUSED", req.query);
    res.render('error', {});
  }
});


router.get("/config", function (req, res) {
  render_with_token(req, res, 'config', {
    token: token
  });
});



router.get("/doc", function (req, res) {
  render_with_token(req, res, 'doc');
});


router.get("/about", function (req, res) {
  render_with_token(req, res, 'about');
});




//**************************************************************************************************
// Specific APIs
//**************************************************************************************************
//**************************************************************************************************
// GET - Secured through Web UI
//**************************************************************************************************


router.get("/test1", function (req, res) {
  if (global.loggedin == true) {
    console.log("  **************************************************************************************************");
    console.log("   🚀 Starting GET: Test");
    //console.log(req.body);
    //processing.parse_demo_event()
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

 
  } else {
    console.log("   ❌ OPERATION REFUSED", req.query);

  }
});


router.get("/test", function (req, res) {
  if (global.loggedin == true) {
    console.log("  **************************************************************************************************");
    console.log("   🚀 Starting POST: Test");
    //console.log(req.body);
    var status= processing.test(res)
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

  } else {
    console.log("   ❌ OPERATION REFUSED for Token:", req.headers.token);
    res.render('login', {});
  }

});

//**************************************************************************************************
// POST - Secured through TOKEN
//**************************************************************************************************

router.post("/test", function (req, res) {
  if (req.headers.token == token) {
    console.log("  **************************************************************************************************");
    console.log("   🚀 Starting POST: Test");
    //console.log(req.body);
    processing.test("test")
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

    res.sendStatus(200);
  } else {
    console.log("   ❌ OPERATION REFUSED for Token:", req.headers.token);
    res.sendStatus(401);
  }

});




module.exports = router;