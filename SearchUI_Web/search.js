// Update this variable to point to your domain.
var apigatewayendpoint = 'https://hlh4mflagg.execute-api.us-east-2.amazonaws.com/prod/SearchESIndex';
var volume_api = 'https://2w966j6thk.execute-api.us-east-2.amazonaws.com/dev/nmc-volumes';
var loadingdiv = $('#loading');
var noresults = $('#noresults');
var resultdiv = $('#results');
var searchbox = $('input#search');
var timer = 0;
var arr = [];
var volume;

// Executes the search function 250 milliseconds after user stops typing
searchbox.keyup(function () {
  clearTimeout(timer);
  timer = setTimeout(search, 500);
});

function dropDownData(period) {
  volume = period;
  console.log(period);
}

async function search() {
  // Clear results before searching
  noresults.hide();
  resultdiv.empty();
  loadingdiv.show();
  // Get the query from the user
  if (volume==undefined || volume==" "){
    console.log("no volume selected");
    // throw new Error("Something went badly wrong!");
    loadingdiv.hide();
    noresults.hide();
    var content = document.createElement("div");
    content.innerHTML += "<p class='result-status'><b>No volume was selected</p>";
    resultdiv.append(content);
    return;}

  let query = searchbox.val();
  console.log(query);
  // Only run a query if the string contains at least three characters
  if (query.length > 0) {
    // Make the HTTP request with the query as a parameter and wait for the JSON results
    // let response_volumes = await $.get(apigatewayendpoint, { q: volume, size: 25 }, 'json');
    let response_data = await $.get(apigatewayendpoint, { q: query, size: 25 }, 'json');
    console.log(response_data);
	//console.log(response,'response...');
    // Get the part of the JSON response that we care about
    //let results = response['hits']['hits'];
    if (response_data.length > 0) {
      loadingdiv.hide();
      noresults.hide();
      // Iterate through the results and write them to HTML
      resultdiv.append('<p class="result-status">Found ' + response_data.length + ' results.</p>');
      appendData(resultdiv,response_data);
  } else {
    noresults.show();
  }
}
  loadingdiv.hide();
}

async function start() {
  response = await $.get(volume_api,'json');
  arr = response.split(",");
  var chars = ['[',']','\\','"'];
  replaceAll(chars);
}

function replaceAll(chars) {
  for ( var i=0;i<chars.length;i++) {
      for (var j=0;j<arr.length;j++) {
          var x = String(arr[j])

          x = x.replaceAll(chars[i],'');
          x = x.replaceAll(/\s/g,'')
          arr[j]=x;
      }
      
  }
  console.log(arr);
  appendDropDown(arr);
}

function appendDropDown(arr) {
  var select = document.getElementById("selectVolume");
  for(var i = 0; i < arr.length; i++) {
    var opt = arr[i];
    var el = document.createElement("option");
    el.textContent = opt;
    el.value = opt;
    select.appendChild(el);
}

}


function appendData(resultdiv, data) {
  var count;
    for (var i = 0; i < data.length; i++) {
        var link = document.createElement("h5");
        var content = document.createElement("span");
        var resultBox = document.createElement("div");
        var spanDiv = document.createElement('div');
        resultBox.classList.add("result-box");
        spanDiv.classList.add("result-content");
		
		if (data[i].length > 0) {
      
			for (var j = 0; j < data[i].length; j++) {
        if(data[i][j]._source.volume_name==volume){
          link.innerHTML = "<a class='elasti_link result-title' href="+data[i][j]._source.access_url+">"+data[i][j]._source.object_key+"</a>" + "<br>" ;
          resultBox.append(link);
				  if (data[i][j].highlight.content.length > 0) {
					  for (var k = 0; k < data[i][j].highlight.content.length; k++) {
						  // content.innerHTML += "<span>" + data[i][j].highlight.content[k] + "</span>";
              content.innerHTML += data[i][j].highlight.content[k];
              spanDiv.append(content);
              resultBox.append(spanDiv);
					}
          // spanDiv.append(content)
        resultdiv.append(resultBox);
				}
        // resultBox.append(spanDiv);
        // resultdiv.append(resultBox);
				// stop();
        }
        else{
          noresults.show();
        continue
        }
        
        stop();
			}
		}
    
    }
}
