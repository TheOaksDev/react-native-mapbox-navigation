import { findNodeHandle } from "react-native";
export function runNativeMethod(turboModule, name, nativeRef, args) {
    const handle = findNodeHandle(nativeRef);
    if (!handle) {
        throw new Error(`Could not find handle for native ref ${module}.${name}`);
    }
    // @ts-expect-error TS says that string cannot be used to index Turbomodules.
    // It can, it's just not pretty.
    return turboModule[name](handle, ...args);
}
export function isFunction(fn) {
    return typeof fn === 'function';
}
