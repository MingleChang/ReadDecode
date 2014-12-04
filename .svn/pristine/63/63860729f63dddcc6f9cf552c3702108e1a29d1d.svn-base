function getAllFileNameAndPath(){
    var rootNodes=document.getElementById('sharelist').children;
    var result=[];
    for (var i=0;i<rootNodes.length;i++){
        var fileName=rootNodes[i].getAttribute('data-fn');
        var filePath=rootNodes[i].getElementsByClassName('list-item')[0].href;
        result[i]={fileName:fileName,filePath:filePath};
    }
    return JSON.stringify(result);;
}
function getFileName(){
    return document.getElementsByClassName("file-name")[0].getAttribute('data-fn');
}
function downLoadFile(){
    document.getElementById('fileDownload').click();
}
