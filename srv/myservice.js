const myFirstService = function(srv){
    srv.on('hello',(req)=>{
        return "hello "+ req.data.to +"!";
    });
    }
    module.exports = myFirstService;