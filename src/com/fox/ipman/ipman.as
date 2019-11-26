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
		
	// create IP textfield
		var f = function(){
			if (this.IPPointer){
				this.IPPointer.removeTextField();
			}
			if (!this.m_IsNPC){
				if (this.m_HealthBar){
					var Format:TextFormat = new TextFormat("_StandardFont", 8,0xFFFFFF,false);
					var field:TextField = this.m_HealthBar.createTextField("m_IPText", this.m_HealthBar.getNextHighestDepth(), this.m_HealthBar.m_Bar._x, this.m_HealthBar.m_Bar._height,20,20);
					field.autoSize = true;
					field.filters = [new DropShadowFilter(20, 45, 0, 1, 0, 0, 107, 2, false, false, false)];
					field.setNewTextFormat(Format);
					field.setTextFormat(Format);
					this.IPPointer = field;
				}else{
					var Format:TextFormat = new TextFormat("_StandardFont", 8,0xFFFFFF,false);
					var field:TextField = this.createTextField("m_IPText", this.getNextHighestDepth(), 0, this.m_Name.textHeight+1,20,20);
					field.autoSize = true;
					field.filters = [new DropShadowFilter(20, 45, 0, 1, 0, 0, 107, 2, false, false, false)];
					field.setNewTextFormat(Format);
					field.setTextFormat(Format);
					this.IPPointer = field;
				}
				this.IPPointer.text = "IP " + this.m_Character.GetStat(2000607);
			}
			
		}
		_global.com.Components.Nametag.prototype.InitIP = f;

	// Redraw when selecting player
		f = function(bool){
			arguments.callee.base.apply(this, arguments);
			this.InitIP();
		}
		f.base = _global.com.Components.Nametag.prototype.SetAsTarget;
		_global.com.Components.Nametag.prototype.SetAsTarget = f;
	
	// Redraw when setting target
		f = function(id){
			arguments.callee.base.apply(this, arguments);
			this.InitIP();
		}
		f.base = _global.com.Components.Nametag.prototype.SetDynelID;
		_global.com.Components.Nametag.prototype.SetDynelID = f;
	
	// Stats changed	
		f = function(statID){
			arguments.callee.base.apply(this, arguments);
			if (statID == 2000607){
				this.IPPointer.text = "IP " + this.m_Character.GetStat(2000607);
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