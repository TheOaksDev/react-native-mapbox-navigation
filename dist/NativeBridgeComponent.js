var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import { runNativeMethod } from "./utils";
const NativeBridgeComponent = (Base, turboModule) => class extends Base {
    constructor(...args) {
        super(...args);
        this._turboModule = turboModule;
        this._preRefMapMethodQueue = [];
    }
    _runPendingNativeMethods(nativeRef) {
        return __awaiter(this, void 0, void 0, function* () {
            if (nativeRef) {
                while (this._preRefMapMethodQueue.length > 0) {
                    const item = this._preRefMapMethodQueue.pop();
                    if (item && item.method && item.resolver) {
                        const res = yield this._runNativeMethod(item.method.name, nativeRef, item.method.args);
                        item.resolver(res);
                    }
                }
            }
        });
    }
    _runNativeMethod(methodName, nativeRef, args = []) {
        if (!nativeRef) {
            return new Promise((resolve) => {
                this._preRefMapMethodQueue.push({
                    method: { name: methodName, args },
                    resolver: resolve,
                });
            });
        }
        return runNativeMethod(this._turboModule, methodName, nativeRef, args);
    }
};
export default NativeBridgeComponent;
