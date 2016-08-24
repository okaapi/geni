function draw_vis( current, nodes, edges, is_editor ) {

  var optionsFA = {
    physics:{
	  hierarchicalRepulsion: {
		springConstant: 0.05,
		nodeDistance: 150,
		damping: 0.017  // very sensitive!
	  },
	  maxVelocity: 50,
	  minVelocity: 0.1,
	  solver: 'hierarchicalRepulsion'// 'forceAtlas2based' 'repulsion' ,	 'barnesHut'  
    },   
    edges: {
      labelHighlightBold: false,
      smooth: {
        type: 'cubicBezier',  
		forceDirection: 'vertical',
        roundness: 0.5
      }
    },
    interaction: {
      navigationButtons: true,
      keyboard: true,
      hover: true
    },
     
    groups: {
      unions: {
        shape: 'icon',
        icon: {
          background: 'blue',
          face: 'FontAwesome',
          code: '\uf228',
          size: 25,
          color: '#551a8b'
        },
        font: {background: 'white'}
      },
      newunion: {
        shape: 'icon',
        icon: {
          background: 'blue',
          face: 'FontAwesome',
          code: '\uf228',
          size: 20,
          color: '#999999'
        },
        font: {background: 'white'}
      },      
      guys: {
        shape: 'icon',
        icon: {
          face: 'FontAwesome',
          code: '\uf007',
          size: 50,
          color: '#00bfff'
        },
		font: { background: 'white' },
	    labelHighlightBold: false,
	    title: 'double click to focus'
      },
      gals: {
        shape: 'icon',
        icon: {
          face: 'FontAwesome',
          code: '\uf007',
          size: 50,
          color: '#ff1493'
        },
		font: {background: 'white'},
		labelHighlightBold: false,
		title: 'double click to focus'
      },
      newperson: {
        shape: 'icon',
        icon: {
          face: 'FontAwesome',      
          code: '\uf007',
          size: 30,
          color: '#999999'
        },
		font: {background: 'white', size: 10}
      }      
    }
  };
 

 
  // create a network
  var containerFA = document.getElementById('geni-graphcontainer');
  var dataFA = {
    nodes: nodes,
    edges: edges
  };
 
  var networkFA = new vis.Network(containerFA, dataFA, optionsFA);
 
  networkFA.on("doubleClick", function (params) {
    //console.log( '#' + params.nodes[0] + '#' + params.edges[0] + '#' );
    //alert( JSON.stringify(params, null, 4) ); 
    payload = params.nodes[0] 
    type = 'node'
    if ( !payload ) {
      payload = params.edges[0]
      type = 'edge'
    }
    if( payload ) {
      if( payload == current && is_editor ) {
        $.get( "/edit/" + current + '?editable=true', function() {} );
      }
      else if( payload == current ) {
        $.get( "/edit/" + current + '?editable=false', function() {} );
      }      
      else if( payload.match(/^NIL/) && is_editor ){
        alert( "can only edit marriages of person in focus" );
      }      
      else if( payload.match(/^NIL/) ){
      }      
      else if( payload.match(/^XHR/) ){
        payload = payload.substring(3,payload.length);
        $.get( payload, function() {} );
      }
      else if( payload.match(/^CONF/) ){
        payload = payload.substring(4,payload.length);
        if( confirm('Are you sure?' ) ) {
          window.open( payload,"_self");
        }
      }        
      else if( payload.match(/^GET/) ){false
        payload = payload.substring(3,payload.length);
        window.open( payload,"_self");
      }      
      else {
        window.open("/" + payload,"_self");
      }
    }
  });   

  networkFA.on("hoverNode", function (params) {
    console.log( 'NODE:' + params.node );
  });
  networkFA.on("hoverEdge", function (params) {
    console.log( 'EDGE:' + params.edge );
  });  

}
