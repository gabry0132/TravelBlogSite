var mysql = require('mysql');       //node.jsのmysqlパッケージへアクセス

const [,, sql] = process.argv;      //cmdのパラメータを取得します。

var connection = mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "root",
    database: "blog_site"
});

connection.connect(function(error) {
    if (error) throw error;
    connection.query(sql, function (error, result, fields) {	//今現在使用不要ですがfieldsも設定しておきます
        if (error) throw error;
        console.log(result.affectedRows + " row updated");
        //接続を終了させないとcmdの操作ができなくなります。
        connection.end(function(err) {
            if (err) throw err;
        });
    });
});