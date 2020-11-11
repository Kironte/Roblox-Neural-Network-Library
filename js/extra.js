var functionTags = document.getElementsByClassName("function");

function objectToHTML(str) {
    str = str.trim()
    var info = str.split(" ")
    var typeText = info[0]
    var valueText = info[1]

    var objectTag = document.createElement("span")
    objectTag.className = "object"

    var typeTag = document.createElement("code")
    typeTag.className = "type"
    typeTag.innerText = typeText
    objectTag.appendChild(typeTag)

    if (valueText) {
        var valueTag = document.createElement("code")
        valueTag.className = "value"
        valueTag.innerText = valueText
        objectTag.appendChild(valueTag)
    }
    
    return objectTag
}

function funcToHTML(str,descriptionStr) {
    var bracketStartIndex = str.indexOf("(")
    var funcName = str.slice(0,bracketStartIndex)

    var arguments = str.slice(bracketStartIndex+1,str.length-1).split(",")
    var argumentTag = document.createElement("span")
    argumentTag.className = "arguments"
    argumentTag.appendChild(document.createTextNode("( "))

    for (var i=0; i<arguments.length; i++) {
        argumentTag.appendChild(objectToHTML(arguments[i]))

        var info = arguments[i].split(" ")
        
        if (info[1]) {
            descriptionStr = descriptionStr.replace(new RegExp("!"+info[1]+"!","g"),"<code class=variable>"+info[1]+"</code>")
        }

        if (i < arguments.length-1) {
            argumentTag.appendChild(document.createTextNode(" , "))
        }
    }
    argumentTag.appendChild(document.createTextNode(" )"))

    var nameTag = document.createElement("code")
    nameTag.className = "name"
    nameTag.innerText = funcName

    return {nameTag,argumentTag,descriptionStr}
}

for (var i=0; i<functionTags.length; i++) {
    var functionTag = functionTags[i]
    var functionStr = functionTag.innerText
    var descriptionStr = functionTag.getElementsByClassName("description")[0].innerHTML
    console.log(descriptionStr)
    functionTag.innerHTML = ""

    var squareEndIndex = functionStr.indexOf("]")
    var squareStr = functionStr.slice(1,squareEndIndex)
    functionStr = functionStr.slice(squareEndIndex+1,functionStr.indexOf(")")+1).trim()

    var tableTag = document.createElement("table")
    functionTag.appendChild(tableTag)
    var tableBodyTag = document.createElement("tbody")
    tableTag.appendChild(tableBodyTag)
    var rowTag = document.createElement("tr")
    tableBodyTag.appendChild(rowTag)
    var colTag1 = document.createElement("td")
    rowTag.appendChild(colTag1)
    var colTag2 = document.createElement("td")
    colTag2.className = "description"
    rowTag.appendChild(colTag2)

    var containerTag = document.createElement("span")
    containerTag.className = "container"
    colTag1.appendChild(containerTag)
    
    
    var {nameTag,argumentTag,descriptionStr} = funcToHTML(functionStr,descriptionStr)
    containerTag.appendChild(objectToHTML(squareStr))
    containerTag.appendChild(nameTag)
    containerTag.appendChild(argumentTag)

    colTag2.innerHTML = descriptionStr

    
    //functionTag.appendChild(document.createElement("br"))

    console.log(squareStr)
    console.log(functionStr)
    //functionTag.appendChild(objectToHTML(functionTag.innerText))
}