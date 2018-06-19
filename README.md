# Wave 与 Amr 互转（Swift）
## 准备工作  

由于用到了 `opencore-amr` 库（https://sourceforge.net/projects/opencore-amr/ ），所以需要在 `Build Settings`->`Objective-C Bridging Header` 所设置的头文件中导入头文件 `AmrCodec.h`  

```
#import "AmrCodec.h"
```

## 用法  

直接调用如下方法，并将对应的音频数据作为参数传入，如果转换失败将返回 `nil`。
```
// 将采样率为 8k Hz 的 wave 格式音频数据转为 amr-nb 格式的数据，如果 wave 为双声道，则只取左声道
public func convert8khzWaveToAmr(waveData data : Data) -> Data?

// 将采样率为 16k Hz 的 wave 格式音频数据转为 amr-wb 格式的数据，如果 wave 为双声道，则只取左声道
public func convert16khzWaveToAmr(waveData data : Data) -> Data?

// 将 amr-nb 格式的数据（单声道），转为 wave 格式
// wave 采用 8k Hz，单声道，16 位
func convertAmrNBToWave(data : Data) -> Data?

// 将 amr-wb 格式的数据（单声道），转为 wave 格式
// wave 采用 16k Hz，单声道，16 位
func convertAmrWBToWave(data : Data) -> Data?
```

## 许可 
此项目采用 MIT 协议
