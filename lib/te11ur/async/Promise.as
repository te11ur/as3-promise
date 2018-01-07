package te11ur.async
{

	import flash.utils.setTimeout;

	public class Promise
	{
		private const resolvers:Array = [];
		private const rejections:Array = [];
		private var status:String = "pending";

		public static function all(promises:Array):Promise
		{
			const length:uint = promises.length;
			const results:Array = new Array(length);

			return new Promise(function (resolve:Function, reject:Function):void {
				for (var i:uint = 0; i < length; i++) {
					const p:Promise = promises[i];
					var f:uint = 0;
					p.then(function (result:*):void {
						const j:uint = promises.indexOf(this);
						results[j] = result;
						(++f == length) && resolve(results);
					}, function (error:*):void {
						reject(error);
					});
				}
			});
		}

		public static function race(promises:Array):Promise
		{
			const length:uint = promises.length;

			return new Promise(function (resolve:Function, reject:Function):void {
				for (var i:uint = 0; i < length; i++) {
					const p:Promise = promises[i];
					p.then(function (result:*):void {
						resolve(result);
					}, function (error:*):void {
						reject(error);
					});
				}
			});
		}

		public static function resolve(result:*):Promise
		{
			return new Promise(function (resolve:Function, reject:Function):void {
				resolve(result);
			});
		}

		public static function reject(error:*):Promise
		{
			return new Promise(function (resolve:Function, reject:Function):void {
				reject(error);
			});
		}

		public function Promise(callback:Function)
		{
			const that:Promise = this;

			const resolve:Function = function (result:*):void {
				if (status != "pending") {
					return;
				}
				status = "fulfilled";
				var c:Function = null;
				var r:* = result;
				while (that.resolvers.length > 0 && (c = (that.resolvers.shift() as Function))) {
					r = c.call(that, r);
					if (r is Promise) {
						(r as Promise).reset(that.resolvers, that.rejections);
						return;
					}
				}
			};

			const reject:Function = function (error:*):void {
				if (status != "pending") {
					return;
				}
				status = "rejected";

				var c:Function = null;
				var r:* = error;
				while (that.rejections.length > 0 && (c = (that.rejections.shift() as Function))) {
					r = c.call(that, r);
				}
			};

			setTimeout(function ():void {
				try {
					callback.call(that, resolve, reject);
				} catch (e:Error) {
					reject(e);
				}
			}, 0);
		}

		public function reset(resolvers:Array, rejections:Array):Promise
		{
			this.resolvers.length = 0;
			this.rejections.length = 0;
			this.resolvers.push.apply(this, resolvers);
			this.rejections.push.apply(this, rejections);
			return this;
		}

		public function then(resolve:Function = null, reject:Function = null):Promise
		{
			if (resolve is Function && resolvers.indexOf(resolve) < 0) {
				resolvers.push(resolve);
			}

			if (reject is Function && rejections.indexOf(reject) < 0) {
				rejections.push(reject);
			}

			return this;
		}

		public function catch_(reject:Function):Promise
		{
			return then(null, reject);
		}
	}
}
