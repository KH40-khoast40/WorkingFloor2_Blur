////////////////////////////////////////////////////////////////////////////////////////////////
//
//  WorkingFloor2_Blur ver0.0.8_edit_1.0  オフスクリーンレンダを使った床面鏡像描画，床に仕事をさせます
//  作成: 針金P( 舞力介入P氏のMirror.fx, full.fx,改変 )
//
//	Blur function added by KH40 (https://github.com/KH40-khoast40/WorkingFloor2_Blur)
//
////////////////////////////////////////////////////////////////////////////////////////////////

#define Resolution 1.0 //1.0 is the highest resolution. 0.2 is the lowest resolution with acceptable result when being blurred

// ここのパラメータを変更してください

#define XFileMirror  0  // アクセサリ(XFile)も鏡像化する時はここを1にする

#define FLG_EXCEPTION  0  // MMDでモデル鏡像が正常に描画されない場合はここを1にする


// 解らない人はここから下はいじらないでね

float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass = "sceneorobject";
	string ScriptOrder = "standard";
> = 0.8;

////////////////////////////////////////////////////////////////////////////////////////////////

// 座標変換行列
float4x4 WorldMatrix     : WORLD;
float4x4 ViewMatrix      : VIEW;
float4x4 ProjMatrix      : PROJECTION;
float4x4 ViewProjMatrix  : VIEWPROJECTION;

//カメラ位置
float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// 透過値
float Blur : CONTROLOBJECT < string name = "(self)"; string item = "Blur"; >;
float Transparency : CONTROLOBJECT < string name = "(self)"; string item = "Transparency"; >;


#ifndef MIKUMIKUMOVING
    #if(FLG_EXCEPTION == 0)
        #define OFFSCREEN_FX_OBJECT  "WF_Object.fxsub"      // オフスクリーン鏡像描画エフェクト
    #else
        #define OFFSCREEN_FX_OBJECT  "WF_ObjectExc.fxsub"   // オフスクリーン鏡像描画エフェクト
    #endif
    #define ADD_HEIGHT   (0.05f)
    #define GET_VPMAT(p) (ViewProjMatrix)
#else
    #define OFFSCREEN_FX_OBJECT  "WF_Object_MMM.fxsub"  // オフスクリーン鏡像描画エフェクト
    #define ADD_HEIGHT   (0.01f)
    #define GET_VPMAT(p) (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : ViewProjMatrix)
#endif


// 床面鏡像描画のオフスクリーンバッファ
texture WorkingFloorRT : OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for WorkingFloor.fx";
    float2 ViewPortRatio = {Resolution,Resolution};
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"

        "*.pmd =" OFFSCREEN_FX_OBJECT ";"
        "*.pmx =" OFFSCREEN_FX_OBJECT ";"
        #if(XFileMirror == 1)
        "*.x=   " OFFSCREEN_FX_OBJECT ";"
        "*.vac =" OFFSCREEN_FX_OBJECT ";"
        #endif

        "* = hide;" ;
>;
sampler WorkingFloorView = sampler_state {
    texture = <WorkingFloorRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture BlurX : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler BlurXSamp = sampler_state {
    texture = <BlurX>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture BlurY : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler BlurYSamp = sampler_state {
    texture = <BlurY>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

#define EXTENT  0.004
#define  WT_0  0.0920246
#define  WT_1  0.0902024
#define  WT_2  0.0849494
#define  WT_3  0.0768654
#define  WT_4  0.0668236
#define  WT_5  0.0558158
#define  WT_6  0.0447932
#define  WT_7  0.0345379

// スクリーンサイズ
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5f, 0.5f)/ViewportSize;
static float2 SampStep = (float2(EXTENT,EXTENT)/ViewportSize*ViewportSize.y);

////////////////////////////////////////////////////////////////////////////////////////////////
//床面鏡像描画

struct VS_OUTPUT {
    float4 Pos  : POSITION;
    float4 VPos : TEXCOORD1;
};

VS_OUTPUT VS_Mirror(float4 Pos : POSITION)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // ワールド座標変換
    Pos = mul( Pos, WorldMatrix );
    Pos.y += ADD_HEIGHT;  // 床と重なってちらつくのを回避するため

    // カメラ視点のビュー射影変換
    Pos = mul( Pos, GET_VPMAT(Pos) );

    Out.Pos = Pos;
    Out.VPos = Pos;

    return Out;
}

float4 PS_Mirror(VS_OUTPUT IN) : COLOR
{
    // 鏡像のスクリーンの座標(左右反転しているので元に戻す)
    float2 texCoord = float2( 1.0f - ( IN.VPos.x/IN.VPos.w + 1.0f ) * 0.5f,
                              1.0f - ( IN.VPos.y/IN.VPos.w + 1.0f ) * 0.5f ) + ViewportOffset;

    // 鏡像の色
    float4 Color = tex2D(BlurYSamp, texCoord);
    Color.a *= (1-Transparency);

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT_BLUR {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT_BLUR VS_Blur( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) 
{
    VS_OUTPUT_BLUR Out = (VS_OUTPUT_BLUR)0; 
    
    //Pos = mul( Pos, WorldMatrix );
    //Pos.y += ADD_HEIGHT;  // 床と重なってちらつくのを回避するため

    // カメラ視点のビュー射影変換
    //Pos = mul( Pos, GET_VPMAT(Pos) );

    Out.Pos = Pos;

    Out.Tex = Tex + float2(ViewportOffset.x, ViewportOffset.y);
    
    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////

float4 PS_BlurX( float2 Tex : TEXCOORD0 ) : COLOR 
{   
    float4 Color;
    float step = SampStep.x * (Blur*2);

    Color  = WT_0 *   tex2D( WorkingFloorView, Tex );
    Color += WT_1 * ( tex2D( WorkingFloorView, Tex+float2(step  ,0) ) + tex2D( WorkingFloorView, Tex-float2(step  ,0) ) );
    Color += WT_2 * ( tex2D( WorkingFloorView, Tex+float2(step*2,0) ) + tex2D( WorkingFloorView, Tex-float2(step*2,0) ) );
    Color += WT_3 * ( tex2D( WorkingFloorView, Tex+float2(step*3,0) ) + tex2D( WorkingFloorView, Tex-float2(step*3,0) ) );
    Color += WT_4 * ( tex2D( WorkingFloorView, Tex+float2(step*4,0) ) + tex2D( WorkingFloorView, Tex-float2(step*4,0) ) );
    Color += WT_5 * ( tex2D( WorkingFloorView, Tex+float2(step*5,0) ) + tex2D( WorkingFloorView, Tex-float2(step*5,0) ) );
    Color += WT_6 * ( tex2D( WorkingFloorView, Tex+float2(step*6,0) ) + tex2D( WorkingFloorView, Tex-float2(step*6,0) ) );
    Color += WT_7 * ( tex2D( WorkingFloorView, Tex+float2(step*7,0) ) + tex2D( WorkingFloorView, Tex-float2(step*7,0) ) );
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

float4 PS_BlurY(float2 Tex : TEXCOORD0 ) : COLOR
{   
    float4 Color;
    float step = SampStep.y * (Blur*2);
    
    Color  = WT_0 *   tex2D( BlurXSamp, Tex );
    Color += WT_1 * ( tex2D( BlurXSamp, Tex+float2(0,step  ) ) + tex2D( BlurXSamp, Tex-float2(0,step  ) ) );
    Color += WT_2 * ( tex2D( BlurXSamp, Tex+float2(0,step*2) ) + tex2D( BlurXSamp, Tex-float2(0,step*2) ) );
    Color += WT_3 * ( tex2D( BlurXSamp, Tex+float2(0,step*3) ) + tex2D( BlurXSamp, Tex-float2(0,step*3) ) );
    Color += WT_4 * ( tex2D( BlurXSamp, Tex+float2(0,step*4) ) + tex2D( BlurXSamp, Tex-float2(0,step*4) ) );
    Color += WT_5 * ( tex2D( BlurXSamp, Tex+float2(0,step*5) ) + tex2D( BlurXSamp, Tex-float2(0,step*5) ) );
    Color += WT_6 * ( tex2D( BlurXSamp, Tex+float2(0,step*6) ) + tex2D( BlurXSamp, Tex-float2(0,step*6) ) );
    Color += WT_7 * ( tex2D( BlurXSamp, Tex+float2(0,step*7) ) + tex2D( BlurXSamp, Tex-float2(0,step*7) ) );
	
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//テクニック

float4 ClearColor = {1,1,1,0};
float ClearDepth  = 1.0;

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;

technique MainTec
<string MMDPass = "object"; string Script=
		"RenderColorTarget0=BlurX;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
		"Pass=DrawBlurX;"
		"RenderColorTarget0=BlurY;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=DrawBlurY;"
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=DrawObject;"
;>
{
    pass DrawObject{
        VertexShader = compile vs_2_0 VS_Mirror();
        PixelShader  = compile ps_2_0 PS_Mirror();
    }
	pass DrawBlurX < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Blur();
        PixelShader  = compile ps_3_0 PS_BlurX();
    }
    pass DrawBlurY < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Blur();
        PixelShader  = compile ps_3_0 PS_BlurY();
    }
}

technique MainTec_ss
<string MMDPass = "object_ss"; string Script=
		"RenderColorTarget0=BlurX;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
		"Pass=DrawBlurX;"
		"RenderColorTarget0=BlurY;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=DrawBlurY;"
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=DrawObject;"
;>
{
    pass DrawObject{
        VertexShader = compile vs_2_0 VS_Mirror();
        PixelShader  = compile ps_2_0 PS_Mirror();
    }
	pass DrawBlurX < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Blur();
        PixelShader  = compile ps_3_0 PS_BlurX();
    }
    pass DrawBlurY < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Blur();
        PixelShader  = compile ps_3_0 PS_BlurY();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////

//描画しない
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }



