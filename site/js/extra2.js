//--------------FUNCTION DOCUMENTATION---------------//

var functionDocTags = document.getElementsByClassName("functionDoc");
const DESCRIPTION_END_SYMBOL = "//"
/*
<span class=functionDoc>

abstract Tuple FuncName(bool wrong)
Some desc//
bool lol,array main

</span>
*/

function funcToHTML(functionStr) {
    //Divide the syntax into 3 strings
    let bracketEndIndex = functionStr.indexOf(")")+1
    let signatureStr = functionStr.slice(0,bracketEndIndex).trim()

    let descStr = functionStr.slice(bracketEndIndex).trim()
    let returnStr
    let descEndSymbol = functionStr.indexOf(DESCRIPTION_END_SYMBOL)
    if (descEndSymbol != -1) {
        descStr = functionStr.slice(bracketEndIndex,descEndSymbol).trim()
        returnStr = functionStr.slice(descEndSymbol+DESCRIPTION_END_SYMBOL.length).trim()
    }
    
    //Process signature string------------------
    let isAbstract = false
    let abstractIndex = signatureStr.indexOf("abstract")
    if (abstractIndex != -1) {
        isAbstract = true
        signatureStr = signatureStr.slice(8).trim()
    }

    let funcType = signatureStr.slice(0,signatureStr.indexOf(" "))
    signatureStr = signatureStr.slice(signatureStr.indexOf(" ")).trim()
    
    let funcName = signatureStr.slice(0,signatureStr.indexOf("("))
    signatureStr = signatureStr.slice(signatureStr.indexOf("(")).trim()

    function argumentStrToDict(argumentStr) {
        let argumentType = argumentStr.slice(0,argumentStr.indexOf(" "))
        argumentStr = argumentStr.slice(argumentStr.indexOf(" ")).trim()

        let argumentName = argumentStr.trim()
        let defaultValue
        let defaultValueIndex = argumentStr.indexOf("=")
        if (defaultValueIndex != -1) {
            argumentName = argumentStr.slice(0,defaultValueIndex).trim()
            argumentStr = argumentStr.slice(defaultValueIndex+1).trim()

            defaultValue = argumentStr
        }
        //Highlight variable mentions in description
        descStr = descStr.replace(new RegExp("!"+argumentName+"!","g"),"<code class=varMention>"+argumentName+"</code>")
        
        let argumentDict = {Type:argumentType,Name:argumentName,Default:defaultValue}

        return argumentDict
    }

    let argumentsStr = signatureStr.slice(1,signatureStr.length-1).trim().split(",")
    let argumentsData = []
    for (let argNum = 0; argNum < argumentsStr.length; argNum++) {
        let argumentStr = argumentsStr[argNum].trim()

        let argumentDict = argumentStrToDict(argumentStr)

        argumentsData.push(argumentDict)
    }
    //------------------------------------

    //Process Description string----------

    //------------------------------------

    //Process Return String---------------
    let returnData
    if (returnStr) {
        if (funcType == "Tuple") {
            returnData = []

            let argumentsStr = returnStr.trim().split(",")
            for (let argNum = 0; argNum < argumentsStr.length; argNum++) {
                let argumentStr = argumentsStr[argNum].trim()

                let argumentDict = argumentStrToDict(argumentStr)

                returnData.push(argumentDict)
            }
        } else if(funcType == "dictionary") {
            returnData = {}

            let keyValuesStr = returnStr.slice(1,returnStr.length-1).trim().split(",")
            
            for (let keyValueNum = 0; keyValueNum < keyValuesStr.length; keyValueNum++) {
                let keyValueStr = keyValuesStr[keyValueNum]
                let [key,value] = keyValueStr.split("=")
                
                returnData[key.trim()] = value.trim()
            }
           
        }
    }
    //------------------------------------

    //----------***Creating the HTML***-------------------

    /*  Data available:
    isAbstract, funcType, funcName, argumentsData, descStr, returnData
    */

    let mainTag = document.createElement("div")
    mainTag.className = "functionDocGrid"

    //Signature Tag---------------
    let signatureTag = document.createElement("div")
    signatureTag.className = "functionDocSig"
    mainTag.appendChild(signatureTag)

    let sigHTML = ""
    if (isAbstract) {
        sigHTML += "<code class=abstract>abstract </code>"
    }
    sigHTML += "<code class=varType>"+funcType+" </code>"
    sigHTML += "<code class=funcName>"+funcName+"</code>"
    sigHTML += " ( "
    for (let i=0; i<argumentsData.length; i++) {
        let argument = argumentsData[i]
        sigHTML += "<code class=varType>"+argument.Type+" </code>"
        sigHTML += "<code class=varName>"+argument.Name+"</code>"
        if (argument.Default) {
            if (argument.Default == "true" || argument.Default == "false") {

                sigHTML += " = "+"<code class='varDefault varBool'>"+argument.Default+"</code>"

            } else if (!isNaN(argument.Default)) {

                sigHTML += " = "+"<code class='varDefault varNum'>"+argument.Default+"</code>"

            } else if (argument.Default.indexOf(`"`) != -1 || argument.Default.indexOf(`'`) != -1) {

                sigHTML += " = "+"<code class='varDefault varStr'>"+argument.Default+"</code>"

            } else {
                sigHTML += " = "+"<code class=varDefault>"+argument.Default+"</code>"
            }
        }
        if (i <argumentsData.length-1) {
            sigHTML += ", "
        }
    }
    sigHTML += " ) "
    
    signatureTag.innerHTML = sigHTML
    //----------------------------

    //Return Tag------------------
    if (returnData) {
        let returnTag = document.createElement("div")
        returnTag.className = "functionDocReturn"
        mainTag.appendChild(returnTag)

        let returnHTML = "<code class=returns>Returns: </code>"
        if (funcType == "Tuple") {
            for (let i=0; i<returnData.length; i++) {
                let argument = returnData[i]
                returnHTML += "<code class=varType>"+argument.Type+" </code>"
                returnHTML += "<code class=varName>"+argument.Name+"</code>"
                if (argument.Default) {
                    returnHTML += " = "+"<code class=varDefault>"+argument.Default+"</code>"
                }
                if (i <returnData.length-1) {
                    returnHTML += " , "
                }
            }
        } else if (funcType == "dictionary") {
            returnHTML += "{ "

            let numOfArguments = 0
            for (let key in returnData) {
                numOfArguments++
            }

            let argNum = 1
            for (let key in returnData) {
                let value = returnData[key]

                returnHTML += "<code class=key>"+key+"</code> = "
                returnHTML += "<code class=value>"+value+"</code>"

                if (argNum < numOfArguments) {
                    returnHTML += " , "
                }
                argNum++
            }

            returnHTML += " }"
        }

        returnTag.innerHTML = returnHTML
    }
    //----------------------------

    //Description Tag-------------
    let descTag = document.createElement("div")
    descTag.className = "functionDocDesc"
    mainTag.appendChild(descTag)
    
    descTag.innerHTML = descStr
    //----------------------------

    return mainTag
}

for (let i=0; i<functionDocTags.length; i++) {
    let functionDocTag = functionDocTags[i]
    let functionStr = functionDocTag.innerHTML
    let functionNewTag = funcToHTML(functionStr)

    functionDocTag.innerHTML = ""
    functionDocTag.appendChild(functionNewTag)

}

//---------FUNCTION DOCUMENTATION END--------------------------

//---------NAVIGATION EXPAND-----------------------------------
let navExpandableTags = document.getElementsByClassName("md-nav__toggle md-toggle");

for (let i=1; i<navExpandableTags.length; i++) {
    let navExpandableTag = navExpandableTags[i]

    if (navExpandableTag.id != "__toc") {
        let navExpandableTextTag = navExpandableTag.parentElement.querySelector("label").firstChild
        navExpandableTextTag.parentElement.style.fontStyle = "italic"
        navExpandableTextTag.parentElement.style.color = "rgb(0,0,0,0.7)"

        let checked = localStorage.getItem(navExpandableTextTag.nodeValue.trim()) == "true"
        navExpandableTag.checked = checked
        console.log(checked)
    }
}

let navScroll = document.getElementsByClassName("md-sidebar__scrollwrap")[0]

window.addEventListener("load", () => {
    let navScrollTop = parseInt(localStorage.getItem("navScroll"),10)
    if (navScrollTop) {
        navScroll.scrollTop = navScrollTop
    }
})

window.addEventListener("beforeunload", () => {
    localStorage.setItem("navScroll",navScroll.scrollTop)
    
    for (let i=1; i<navExpandableTags.length; i++) {
        let navExpandableTag = navExpandableTags[i]
    
        if (navExpandableTag.id != "__toc") {
            let navExpandableTextTag = navExpandableTag.parentElement.querySelector("label").firstChild

            localStorage.setItem(navExpandableTextTag.nodeValue.trim(),navExpandableTag.checked)
        }
    }
})

//-----------NAVIGATION EXPAND END-----------------------------

//-----------TOC-----------------------------------------------
if (window.location.href.indexOf("documentation") != -1) {
    document.getElementsByClassName("md-sidebar md-sidebar--secondary")[0].remove();
}

//-----------TOC END-------------------------------------------