import flash.filters.DropShadowFilter;
import mx.utils.Delegate;
class com.fox.ipman.ipman{
	private var NametagController:MovieClip;
	
	public static function main(swfRoot:MovieClip):Void{
		var s_app = new ipman(swfRoot);
		swfRoot.onLoad = function () {s_app.Hook()};
	}
	public function ipman() { }
	public function Hook(){
		NametagController = _root.nametagcontroller;
		if (_global.com.fox.IPHook){
			return
		}
		if (!_global.com.Components.Nametag.prototype.SetAsTarget){
			setTimeout(Delegate.create(this, Hook), 500);
			return
		}
		
	// create IP field function
		var f = function(){
			if (!this.m_IsNPC){
				if (!this.m_HealthBar.IPField){
					var Format:TextFormat = new TextFormat("_StandardFont", 8,0xFFFFFF,false);
					var IPField:TextField = this.m_HealthBar.createTextField("IPField", this.m_HealthBar.getNextHighestDepth(), this.m_HealthBar.m_HealthBar._x, this.m_HealthBar.m_Bar._height,20,20);
					IPField.autoSize = true;
					IPField.filters = [new DropShadowFilter(20, 45, 0, 1, 0, 0, 107, 2, false, false, false)];
					IPField.setNewTextFormat(Format);
					IPField.setTextFormat(Format);
				}
				this.m_HealthBar.IPField.text = "IP "+this.m_Character.GetStat(2000607);
			}
			
		}
		_global.com.Components.Nametag.prototype.InitIP = f;
	// Target set
		f = function(id){
			arguments.callee.base.apply(this, arguments);
			this.InitIP();
		}
		f.base = _global.com.Components.Nametag.prototype.SetDynelID;
		_global.com.Components.Nametag.prototype.SetDynelID = f;
	
	// Stats changed	
		f = function(statID){
			arguments.callee.base.apply(this, arguments);
			if (!this.m_IsNPC){
				if (statID == 2000607){
					this.m_HealthBar.IPField.text = "IP "+this.m_Character.GetStat(2000607);
				}
			}
		}
		f.base = _global.com.Components.Nametag.prototype.SlotDynelStatChanged
		_global.com.Components.Nametag.prototype.SlotDynelStatChanged = f;
		
	// Update already created nametags
		for (var i in NametagController.m_NametagArray){
			var tag = NametagController.m_NametagArray[i];
			tag.InitIP();
		}
		
		_global.com.fox.IPHook = true;
	}
}