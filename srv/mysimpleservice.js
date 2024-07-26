const cds = require("@sap/cds");
const { employees } = cds.entities("mycap.db.master");
// const proxy = require('@sap/cds-odata-v2-adapter-proxy');
const mysrvdemo = function (srv) {

    // srv.on('bootstrap', app => {
    //     app.use(proxy());
    // });

    srv.on('somesrv', (req, res) => {
        return "hey " + req.data.msg;
    });

    srv.on("READ", "ReadEmoployeeSrv", async(req, res) => {

        var results = [];

        // results.push({
        //     "ID":"02BD2137-0890-1EEA-A6C2-BB55C19787FB",
        //     "nameFirst": "Christiano",
        //     "nameLast":"Ronaldo"
        // });

        //CDS Query Language - SELECT * FROM dbtab
        //results = await cds.tx(req).run(SELECT.from(employees).limit(3));

        //CDS Query to read single record with where
        //results = await cds.tx(req).run(SELECT.from(employees).where({"nameFirst": "Susan"}));

        //CDS Query if user pass key like /Entity/key
        var whereCondition = req.data;
        console.log(whereCondition);
        if(whereCondition.hasOwnProperty("ID")){
            results = await cds.tx(req).run(SELECT.from(employees).where(whereCondition));
        }else{
            results = await cds.tx(req).run(SELECT.from(employees).limit(2));
        }

        return results;
    });


    srv.on("CREATE", "InsertEmployeeSrv", async (req, res) => {
        console.log(req.data);
        var dataSet = [];
        // for (let i = 0; i < req.data.length; i++) {
        //     const element = req.data[i];
        //     var rString = randomString(32, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
        //     element.ID = "02BD2137-0890-1EEA-A6C2-BB55C19787EE";
        //     rString.toUpperCase();
        //     dataSet.push(element);
        // }
        console.log(dataSet);
        let returnData = await cds.transaction(req).run([

            INSERT.into(employees).entries([req.data])

        ]).then((resolve, reject) => {

            if (typeof (resolve) !== undefined) {
                return req.data;
            } else {
                req.error(500, "There was an issue in insert");
            }

        }).catch(err => {
            req.error(500, "there was an error " + err.toString());
        });

        return returnData;

    });


    srv.on("UPDATE", "UpdateEmployeeSrv", async (req, res) => {

        let returnData = await cds.transaction(req).run([

            UPDATE(employees).set({
                nameFirst: req.data.nameFirst
            }).where({ ID: req.data.ID }),

            UPDATE(employees).set({
                nameLast: req.data.nameLast
            }).where({ ID: req.data.ID })

        ]).then((resolve, reject) => {
            if (typeof (resolve) !== undefined) {
                return req.data;
            } else {
                req.error(500, "There was an issue in insert");
            }
        }).catch(err => {
            req.error(500, "there was an error " + err.toString());
        });

        return returnData;

    });

    srv.on("DELETE", "DeleteEmployeeSrv", async (req, res) => {

        let returnData = await cds.transaction(req).run([

            DELETE.from(employees).where(req.data)

        ]).then((resolve, reject) => {
            if (typeof (resolve) !== undefined) {
                return req.data;
            } else {
                req.error(500, "There was an issue in insert");
            }
        }).catch(err => {
            req.error(500, "there was an error " + err.toString());
        });

        return returnData;

    });

}

module.exports = mysrvdemo;