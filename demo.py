#import for server
from flask import Flask, flash, request, jsonify, send_file
import time
from werkzeug.utils import secure_filename
from flask_cors import CORS
import socket
from datetime import datetime
import json
import operator
#import for detect
import sys
sys.path.insert(0, './mmdetection/')
import os
from mmdet.apis import inference_detector, init_detector
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image, ImageDraw, ImageFont
#import for ocr
sys.path.insert(0, './vietocr/')
from vietocr.tool.predictor import Predictor
from vietocr.tool.config import Cfg
#import for visualize
import cv2
import base64


app = Flask(__name__)
cors = CORS(app, resources={r"/*": {"origins": "*", "allow_headers": "*", "expose_headers": "*"}})
app.config['CORS_HEADERS'] = 'Content-Type'
app.secret_key = "secret key"
app.config['UPLOAD_FOLDER'] = "/home/object_detection/K18_ChauHieu/demo/"

config_file = 'faster_rcnn_prroi_r101_uit_mlreceipts_2_2.py'
checkpoint_file = 'epoch_24.pth'
image_path = '/home/object_detection/K18_ChauHieu/demo/temp.jpg'
ocr_checkpoint_path = "/home/object_detection/K18_ChauHieu/demo/transformerocr.pth"
history_path = "/home/object_detection/K18_ChauHieu/demo/history/"


def infor_detect(image_name):
    dict_detection = {}
    score_thr = 0.6
    model = init_detector(config_file, checkpoint_file, device='cuda:0')
    result = inference_detector(model, image_path)
    dict_detection[image_name] = []
    if isinstance(result, tuple):
        bbox_result, segm_result = result
        if isinstance(segm_result, tuple):
            segm_result = segm_result[0]
    else:
        bbox_result, segm_result = result, None
    
    bboxes = np.vstack(bbox_result)
    labels = [
        np.full(bbox.shape[0], i, dtype=np.int32)
        for i, bbox in enumerate(bbox_result)
    ]
    labels = np.concatenate(labels)
    
    scores = bboxes[:, -1]
    inds = scores > score_thr
    bboxes = bboxes[inds, :]
    labels = labels[inds]
    
    for cls, bbox in zip(labels, bboxes):
        dict_detection[image_name].append([str(cls + 15), int(bbox[0]), int(bbox[1]), int(bbox[2]), int(bbox[3]), str(bbox[4])])
    return dict_detection


def ocr(dict_detection, image_name, start_time):
    ocr_result = {}
    config = Cfg.load_config_from_name('vgg_transformer')
    config['vocab'] = 'aAàÀảẢãÃáÁạẠăĂằẰẳẲẵẴắẮặẶâÂầẦẩẨẫẪấẤậẬbBcCdDđĐeEèÈẻẺẽẼéÉẹẸêÊềỀểỂễỄếẾệỆfFgGhHiIìÌỉỈĩĨíÍịỊjJkKlLmMnNoOòÒỏỎõÕóÓọỌôÔồỒổỔỗỖốỐộỘơƠờỜởỞỡỠớỚợỢpPqQrRsStTuUùÙủỦũŨúÚụỤưƯừỪửỬữỮứỨựỰvVwWxXyYỳỲỷỶỹỸýÝỵỴzZ0123456789!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~° '
    config['weights'] = ocr_checkpoint_path
    config['cnn']['pretrained']=False
    config['device'] = 'cuda:0'
    config['predictor']['beamsearch']=False
    detector = Predictor(config)
    seller = ''
    address = ''
    timestamp = ''
    total_cost = ''
    for a in dict_detection[image_name]:
        x1,y1,x2,y2 = max(a[1], 0), max(a[2], 0), a[3], a[4]
        image = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
        crop_img = image[y1:y2,x1:x2]
        w, h = crop_img.shape[1], crop_img.shape[0]
        if w <= h:
            crop_img = cv2.rotate(crop_img, cv2.cv2.ROTATE_90_CLOCKWISE)
        cv2.imwrite("temp_crop.png", crop_img)
        image_ = Image.open("temp_crop.png")
        transcript = detector.predict(image_)
        a.append(transcript)
        if a[0] == '15':
            if seller == '':
                seller = transcript
            else:
                seller = seller + " " + transcript
        else:
            if a[0] == '16':
                if address == '':
                    address = transcript
                else:
                    address = address + " " + transcript
            else:
                if a[0] == '17':
                    if timestamp == '':
                        timestamp = transcript
                    else:
                        timestamp = timestamp + " " + transcript
                else:
                    if a[0] == '18':
                        if total_cost == '':
                            total_cost = transcript
                        else:
                            total_cost = total_cost + " " + transcript
    end_time = time.time()
    test_time = end_time - start_time
    visualize(dict_detection, image_name)
    b64_string = ''
    with open(history_path + image_name, "rb") as img_file:
        b64_string = base64.b64encode(img_file.read())
        
    ocr_result['seller'] = seller
    ocr_result['address'] = address
    ocr_result['timestamp'] = timestamp
    ocr_result['total_cost'] = total_cost
    ocr_result['detect_day'] = str(datetime.fromtimestamp(end_time))
    ocr_result['result_image'] = b64_string.decode("utf-8")
    ocr_result['time'] = round(test_time, 2)
    jsonString = json.dumps(ocr_result)
    jsonFile = open(history_path + image_name.split('.')[0] + '.json', "w")
    jsonFile.write(jsonString)
    jsonFile.close()
    
    #return jsonify(image=image_name,
    #        seller = seller,
    #        address = address,
    #        timestamp = timestamp,
    #        total_cost = total_cost,
    #        result_image = b64_string.decode("utf-8"),
    #        time = round(test_time, 2)), dict_detection
    return jsonString, dict_detection
            
            
def visualize(json_result, image_name):
    img = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
    for a in json_result[image_name]:
        cls = (255, 0, 0)
        if a[0] == '15':
            cls = (255, 0, 0)
        else:
            if a[0] == '16':
                cls = (0, 255, 0)
            else:
                if a[0] == '17':
                    cls = (0, 0, 255)
                else:
                    cls = (255, 0, 255)
        # For bounding box
        l = a[1]
        t = a[2]
        r = a[3]
        b = a[4]
        img = cv2.rectangle(img, (l, t), (r, b), cls, 2)
  
        # For the text background
        # Finds space required by the text so that we can put a background with that amount of width.
        font_size=20
        unicode_font = ImageFont.truetype("Times New Roman 400.ttf", font_size)
        width = unicode_font.getsize(a[6])[0]
          
        img = cv2.rectangle(img, (l, t - 22), (l + width + 6, t), cls, -1)
        #img = cv2.putText(img, a['text'], (l, t - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 0), 1)

        img_pil = Image.fromarray(img)
        draw = ImageDraw.Draw(img_pil)
      
        draw.text((l + 3, t - 22),  a[6], font = unicode_font, fill = (0, 0, 0, 1))
        img = np.array(img_pil)

    cv2.imwrite(history_path + str(image_name), img)
    #img_pil.save(history_path + str(image_name))
    

@app.route('/upload', methods=['POST', 'GET'])
def upload():
    if request.method == 'POST':
        start_time = time.time()
        image_file = request.files['image']
        image_name = image_file.filename
        image_file.save(image_path)

        detect_result = infor_detect(image_name)
        ocr_result, json_result = ocr(detect_result, image_name, start_time)
        
        return ocr_result
    else:
        return jsonify(
            {
                "message": "Image upload unsuccessfully"
            }
        )


@app.route('/history', methods=['GET'])
def get_history():
    predicted_images = os.listdir(history_path)
    images = []
    count = 0
    for anno in predicted_images:
      if ("json" in anno and "removed" not in anno):
        with open(history_path + anno, "rb") as anno_file:
          json_text = json.load(anno_file)
          anno_file.close()
          json_text_str = str(json_text).replace('\'', '"')

          img_dict = {"name": anno, "created": str(datetime.fromtimestamp(os.path.getctime(history_path + anno))), "anno": json_text}
          images.append(img_dict)
          count = count + 1
    num_history = min(10, count)
    # return jsonify(images=sorted(images, key=operator.itemgetter('created'), reverse=True), total=len(predicted_images), time=test_time)
    return jsonify(images=sorted(images, key=operator.itemgetter('created'), reverse=True)[0 : num_history], total=num_history)


@app.route('/delete', methods=['GET'])
def delete():
    remove_file = request.args.get("filename")
    os.rename(os.path.join(history_path, remove_file), os.path.join(history_path, remove_file.split('.')[0] + '_removed.json'))
    return jsonify(noti="Success")
    
@app.route('/deleteall', methods=['GET'])
def delete_all():
    predicted_images = os.listdir(history_path)
    for anno in predicted_images:
        if ("json" in anno and "removed" not in anno):
            os.rename(os.path.join(history_path, anno), os.path.join(history_path, anno.split('.')[0] + '_removed.json'))
    return jsonify(noti="Success")
   
        
@app.route('/testconnection', methods=['GET'])   
def test():
    return jsonify(noti="Success")


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=8000)