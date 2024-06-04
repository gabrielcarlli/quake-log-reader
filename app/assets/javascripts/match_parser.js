function initializeMatchClickEvents() {
  var matches = document.getElementsByClassName('match-box');

  // Mapping of keys to prettier names
  var prettyNames = {
    kills: "Kills",
    deaths: "Deaths",
    world_deaths: "World Deaths",
    final_score: "Final Score",
    kills_per_weapon: "Kills Per Weapon",
    death_causes: "Death Causes",
    self_deaths: "Self Deaths",
    favourite_weapon: "Favourite Weapon",
    extra_details: "Extra Details"
  };

  for (var i = 0; i < matches.length; i++) {
    matches[i].addEventListener('click', function() {
      var matchContent = this.nextElementSibling.innerText;
      var matchData = JSON.parse(matchContent);
      var infoBox = document.getElementById('json-content');
      
      // Clear the infoBox
      infoBox.innerHTML = '';

      // Create a table for each player
      for (var player in matchData.player_info) {
        var table = document.createElement('table');
        var thead = document.createElement('thead');
        var tbody = document.createElement('tbody');

        // Add table header
        var tr = document.createElement('tr');
        var th = document.createElement('th');
        th.textContent = player;
        th.colSpan = 2;
        tr.appendChild(th);
        thead.appendChild(tr);
        table.appendChild(thead);

        // Add player data to the table
        var playerData = matchData.player_info[player];
        for (var key in playerData) {
          var tr = document.createElement('tr');
          var tdKey = document.createElement('td');
          var tdValue = document.createElement('td');
          
          // Use prettier names if available, otherwise use the original key
          tdKey.textContent = prettyNames[key] || key;

          if (typeof playerData[key] === 'object' && playerData[key] !== null) {
            tdValue.appendChild(createNestedTable(playerData[key]));
          } else {
            tdValue.textContent = playerData[key];
          }

          tr.appendChild(tdKey);
          tr.appendChild(tdValue);
          tbody.appendChild(tr);
        }
        table.appendChild(tbody);

        // Add the table to the infoBox
        infoBox.appendChild(table);
      }
    });
  }

  function createNestedTable(nestedData) {
    var miniTable = document.createElement('table');
    miniTable.style.border = '1px solid #ddd';
    miniTable.style.width = '100%';
    miniTable.style.marginTop = '10px'; /* Add margin to nested tables */
    
    for (var subKey in nestedData) {
      var miniTr = document.createElement('tr');
      var miniTdKey = document.createElement('td');
      var miniTdValue = document.createElement('td');
      
      // Use prettier names if available, otherwise use the original subKey
      miniTdKey.textContent = prettyNames[subKey] || subKey;
      
      if (typeof nestedData[subKey] === 'object' && nestedData[subKey] !== null) {
        miniTdValue.appendChild(createNestedTable(nestedData[subKey]));
      } else {
        miniTdValue.textContent = nestedData[subKey];
      }
      
      miniTr.appendChild(miniTdKey);
      miniTr.appendChild(miniTdValue);
      miniTable.appendChild(miniTr);
    }
    return miniTable;
  }
}

// Call the function on window load
document.addEventListener('DOMContentLoaded', initializeMatchClickEvents()); 