package
{

	import flash.display.Sprite;
	import flash.utils.setTimeout;
	import te11ur.async.Promise;

	public class Main extends Sprite
	{
		public function Main()
		{

			var promises:Array = [];
			promises.push(new Promise(function (resolve:Function, reject:Function):void {
				setTimeout(function ():void {
					resolve("1 sec");
				}, 1000);
			}));
			promises.push(new Promise(function (resolve:Function, reject:Function):void {
				setTimeout(function ():void {
					resolve("2 sec");
				}, 2000);
			}));

			/*Promise.all(promises).then(function(finish:Array):void {
				trace(finish);
			});*/
			Promise.race(promises).then(function (ok:String):void {
				trace(ok);
			});
		}
	}
}
